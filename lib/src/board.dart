import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/controllers/states/scroll_state.dart';
import 'package:kanban_board/src/widgets/board-group/board_groups_root.dart';
import 'package:kanban_board/src/widgets/draggable/draggable_overlay.dart';
import 'package:kanban_board/src/widgets/kanban_gesture_listener.dart';
import 'board_inputs.dart';
import 'constants/constants.dart';
import 'controllers/controllers.dart';

typedef CardTransitionBuilder = Widget Function(
    Widget child, Animation<double> animation);

typedef ListTransitionBuilder = Widget Function(
    Widget child, Animation<double> animation);

typedef OnGroupItemMove = void Function(
    int? oldCardIndex, int? newCardIndex, int? oldListIndex, int? newListIndex);

typedef OnGroupMove = void Function(int? oldListIndex, int? newListIndex);

typedef GroupItemBuilder = Widget Function(
    BuildContext context, String groupId, int itemIndex);

typedef GroupHeaderBuilder = Widget Function(
    BuildContext context, String groupId);

typedef GroupFooterBuilder = Widget Function(
    BuildContext context, String groupId);

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({
    this.groups = const [],
    required this.controller,
    required this.groupItemBuilder,
    this.onGroupItemMove,
    this.onGroupMove,
    this.boardScrollConfig = const BoardScrollConfig(),
    this.groupScrollConfig = const GroupScrollConfig(),
    this.boardDecoration,
    this.trailing,
    this.leading,
    this.groupConstraints = const BoxConstraints(maxWidth: 300),
    this.groupDecoration,
    this.groupHeaderBuilder,
    this.groupFooterBuilder,
    super.key,
  });

  /// It is the controller for the board.
  /// It can be used to perform operations like adding a new group, adding a new item to a group, etc.
  final KanbanBoardController controller;

  /// It is the list of groups for the board.
  /// Each group contains a list of group-items.
  /// Each group-item is a card in the board.
  final List<KanbanBoardGroup> groups;

  /// This is called when a group-item is moved from one place to another.
  /// It takes [oldCardIndex], [newCardIndex], [oldListIndex], [newListIndex] as input.
  final OnGroupItemMove? onGroupItemMove;

  /// This is called when a group is moved from one place to another.
  /// It takes [oldListIndex], [newListIndex] as input.
  final OnGroupMove? onGroupMove;

  /// This is the configuration for the board scroll.
  /// It is used to customize the scroll [speed], [curve], and [duration].
  /// Takes [Offset], [Duration], [Curve] as input.
  final ScrollConfig boardScrollConfig;

  /// This is the configuration for the list scroll.
  /// It is used to customize the scroll [speed], [curve], and [duration].
  /// Takes [Offset], [Duration], [Curve] as input.
  final ScrollConfig groupScrollConfig;

  /// This is the decoration for the board.
  final Decoration? boardDecoration;

  /// This is the decoration for the group.
  final Decoration? groupDecoration;

  /// This is the builder for the group-header.
  /// pass the [context], [groupId] to the builder.
  /// it is called for each group.
  final GroupHeaderBuilder? groupHeaderBuilder;

  /// This is the builder for the group-footer.
  /// pass the [context], [groupId] to the builder.
  /// it is called for each group.
  final GroupFooterBuilder? groupFooterBuilder;

  /// This is the widget which is shown after the last group.
  final Widget? trailing;

  /// This is the widget which is shown before the first group.
  final Widget? leading;

  /// This is the builder for the group-item.
  /// pass the [context], [groupId], and [itemIndex] to the builder.
  final GroupItemBuilder groupItemBuilder;

  /// This is the constraints for the group.
  final BoxConstraints groupConstraints;

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Board(
        groups: widget.groups,
        groupItemBuilder: widget.groupItemBuilder,
        controller: widget.controller,
        onGroupItemMove: widget.onGroupItemMove,
        onGroupMove: widget.onGroupMove,
        boardScrollConfig: widget.boardScrollConfig,
        groupScrollConfig: widget.groupScrollConfig,
        boardDecoration: widget.boardDecoration,
        trailing: widget.trailing,
        leading: widget.leading,
        groupConstraints: widget.groupConstraints,
        groupDecoration: widget.groupDecoration,
        groupHeaderBuilder: widget.groupHeaderBuilder,
        groupFooterBuilder: widget.groupFooterBuilder,
      ),
    ));
  }
}

class Board extends ConsumerStatefulWidget {
  const Board({
    this.groups = const [],
    required this.controller,
    required this.groupItemBuilder,
    this.onGroupItemMove,
    this.onGroupMove,
    this.boardScrollConfig = const BoardScrollConfig(),
    this.groupScrollConfig = const GroupScrollConfig(),
    this.boardDecoration,
    this.groupDecoration,
    this.trailing,
    this.leading,
    this.groupConstraints = const BoxConstraints(maxWidth: 300),
    this.groupHeaderBuilder,
    this.groupFooterBuilder,
    super.key,
  });
  final List<KanbanBoardGroup> groups;
  final KanbanBoardController controller;
  final GroupItemBuilder groupItemBuilder;
  final OnGroupItemMove? onGroupItemMove;
  final OnGroupMove? onGroupMove;
  final ScrollConfig boardScrollConfig;
  final ScrollConfig groupScrollConfig;
  final Decoration? boardDecoration;
  final Decoration? groupDecoration;
  final Widget? trailing;
  final Widget? leading;
  final BoxConstraints groupConstraints;
  final GroupHeaderBuilder? groupHeaderBuilder;
  final GroupFooterBuilder? groupFooterBuilder;

  @override
  ConsumerState<Board> createState() => _BoardState();
}

class _BoardState extends ConsumerState<Board> {
  /// [_boardScrollController] is the controller for the board scroll.
  final ScrollController _boardScrollController = ScrollController();

  /// [_boardStateController] is the controller to manage the state of the board.
  late ChangeNotifierProvider<BoardStateController> _boardStateController;
  late ChangeNotifierProvider<GroupItemStateController>
      _groupItemStateController;
  late ChangeNotifierProvider<GroupStateController> _groupStateController;

  /// [_getBoardOffset] is used to compute the offset of the board.
  void _getBoardOffset() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var box = context.findRenderObject() as RenderBox;
    ref.read(_boardStateController).boardOffset = Offset(
        box.localToGlobal(Offset.zero).dx + BOARD_PADDING,
        box.localToGlobal(Offset.zero).dy - statusBarHeight + BOARD_PADDING);
  }

  /// [_initializeBoardGroups] is used to initialize the board groups.
  List<IKanbanBoardGroup> _initializeBoardGroups() {
    List<IKanbanBoardGroup> groups = [];
    for (int index = 0; index < widget.groups.length; index++) {
      final group = widget.groups[index];
      List<IKanbanBoardGroupItem> items = [];
      for (int itemIndex = 0; itemIndex < group.items.length; itemIndex++) {
        items.add(IKanbanBoardGroupItem(
            groupIndex: index,
            id: group.items[itemIndex].id,
            key: GlobalKey(),
            itemWidget: widget.groupItemBuilder(context, group.id, itemIndex),
            ghost: widget.groupItemBuilder(context, group.id, itemIndex),
            index: itemIndex,
            setState: () => {}));
      }
      groups.add(IKanbanBoardGroup(
          id: group.id,
          name: group.name,
          items: items,
          customData: group.customData,
          index: index,
          setState: () => setState(() {}),
          key: GlobalKey()));
    }
    return groups;
  }

  @override
  void initState() {
    ///Initializing the [BoardStateController] provider.
    _boardStateController = ChangeNotifierProvider<BoardStateController>(
        (ref) => BoardStateController(
            groups: _initializeBoardGroups(), controller: widget.controller));

    ///Initializing the [ListItemProvider] provider.
    ///It is used to manage the state of the group-item.
    _groupItemStateController =
        ChangeNotifierProvider<GroupItemStateController>(
            (ref) => GroupItemStateController(ref.read(_boardStateController)));

    ///Initializing the [BoardListProvider] provider.
    ///It is used to manage the state of the group.
    _groupStateController = ChangeNotifierProvider<GroupStateController>(
        (ref) => GroupStateController(ref.read(_boardStateController)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _getBoardOffset());
    return Scaffold(
        backgroundColor: Colors.white,
        body: KanbanGestureListener(
          boardgroupController: _groupStateController,
          boardStateController: _boardStateController,
          groupItemController: _groupItemStateController,
          groupScrollConfig: widget.groupScrollConfig,
          boardScrollConfig: widget.boardScrollConfig,
          boardScrollController: _boardScrollController,
          child: Container(
            padding:
                const EdgeInsets.only(top: BOARD_PADDING, left: BOARD_PADDING),
            decoration: widget.boardDecoration,
            child: Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.none,
              children: [
                BoardGroupsRoot(
                  groupItemBuilder: widget.groupItemBuilder,
                  leading: widget.leading,
                  trailing: widget.trailing,
                  header: widget.groupHeaderBuilder,
                  footer: widget.groupFooterBuilder,
                  groupDecoration: widget.groupDecoration,
                  groupConstraints: widget.groupConstraints,
                  boardStateController: _boardStateController,
                  groupItemStateController: _groupItemStateController,
                  groupStateController: _groupStateController,
                  boardScrollController: _boardScrollController,
                ),
                DraggableOverlay(
                  boardState: _boardStateController,
                  groupState: _groupStateController,
                  boardScrollController: _boardScrollController,
                  groupScrollConfig: widget.groupScrollConfig,
                  boardScrollConfig: widget.boardScrollConfig,
                )
              ],
            ),
          ),
        ));
  }
}

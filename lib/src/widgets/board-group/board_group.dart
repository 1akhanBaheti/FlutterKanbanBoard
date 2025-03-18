import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/constants/constants.dart';
import 'package:kanban_board/src/constants/widget_styles.dart';
import 'package:kanban_board/src/board.dart';
import 'package:kanban_board/src/controllers/controllers.dart';
import 'package:kanban_board/src/widgets/widgets.dart';

class BoardGroup extends ConsumerStatefulWidget {
  const BoardGroup(
      {required this.boardStateController,
      required this.groupIndex,
      required this.groupConstraints,
      required this.groupDecoration,
      required this.itemBuilder,
      required this.groupItemStateController,
      required this.groupStateController,
      this.footer,
      this.header,
      super.key});
  final int groupIndex;
  final ChangeNotifierProvider<BoardStateController> boardStateController;
  final ChangeNotifierProvider<GroupItemStateController>
      groupItemStateController;
  final ChangeNotifierProvider<GroupStateController> groupStateController;
  final BoxConstraints groupConstraints;
  final Decoration? groupDecoration;
  final GroupFooterBuilder? footer;
  final GroupHeaderBuilder? header;
  final GroupItemBuilder? itemBuilder;

  @override
  ConsumerState<BoardGroup> createState() => _BoardGroupState();
}

class _BoardGroupState extends ConsumerState<BoardGroup> {
  /// [_scrollController] is used to control the scroll of the group.
  late ScrollController _scrollController;

  bool resetPlaceholder = false;

  /// It is used to handle the operations on the group.
  /// It is called when an operation is selected on the group through default header popup menu.
  void onOperationSelect(GroupOperationType type) {
    log("Operation selected $type");
  }

  void _activateBoardGroupScrollListeners() {
    final boardState = ref.read(widget.boardStateController);
    final groupState = ref.read(widget.groupStateController);
    for (final group in boardState.groups) {
      // Group Scroll Listener
      //TODO: remove listener on dispose
      group.scrollController.addListener(() {
        if (groupState.isScrolling) {
          /// This is to notify newly group-items came into view.
          /// about the dragging widget position & calculate their position & size to show placeholder.
          boardState.draggingState.feedbackOffset.value = Offset(
              boardState.draggingState.feedbackOffset.value.dx,
              boardState.draggingState.feedbackOffset.value.dy + 0.00001);
        }
      });
    }
  }

  void _onDragUpdate(Offset draggableOffset, VoidCallback setstate) {
    final boardState = ref.read(widget.boardStateController);
    final draggingState = ref.read(widget.boardStateController).draggingState;
    final group = boardState.groups[widget.groupIndex];
    group.setState = setstate;
    if (draggingState.draggableType == DraggableType.none) return;
    var box = context.findRenderObject();
    var groupRenderBox = group.key.currentContext!.findRenderObject();
    if (box == null || groupRenderBox == null) return;
    box = box as RenderBox;
    groupRenderBox = groupRenderBox as RenderBox;
    final groupPosition = groupRenderBox.localToGlobal(Offset.zero);
    group.position = Offset(groupPosition.dx - boardState.boardOffset.dx,
        groupPosition.dy - boardState.boardOffset.dy);
    group
      ..size =
          Size(groupRenderBox.size.width - LIST_GAP, groupRenderBox.size.height)
      ..actualSize =
          group.actualSize == Size.zero ? group.size : group.actualSize;
    if (draggingState.draggableType == DraggableType.item) {
      ref
          .read(widget.groupStateController)
          .handleItemDragOverGroup(widget.groupIndex);
    } else {
      ref
          .read(widget.groupStateController)
          .handleGroupDragOverGroup(widget.groupIndex);
    }
  }

  @override
  void initState() {
    _scrollController = ref
        .read(widget.boardStateController)
        .groups[widget.groupIndex]
        .scrollController;
    _activateBoardGroupScrollListeners();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(widget.boardStateController
        .select((value) => value.groups[widget.groupIndex]));
    final draggingState = ref.read(widget.boardStateController).draggingState;
 
    return ValueListenableBuilder(
      key: group.key,
      valueListenable: draggingState.feedbackOffset,
      builder: (context, draggableOffset, b) {
        _onDragUpdate(draggableOffset, () => setState(() {}));
        return b!;
      },
      child: draggingState.dragStartGroupIndex == widget.groupIndex &&
              draggingState.currentGroupIndex != widget.groupIndex
          ? Container()
          : Opacity(
              // If [this] group is just long pressed to start drag, then show the ghost.
              opacity: draggingState.dragStartGroupIndex == widget.groupIndex &&
                      draggingState.currentGroupIndex == widget.groupIndex
                  ? 0.5
                  : 1,
              child: GroupPlaceholderWrapper(
                groupIndex: widget.groupIndex,
                groupStateController: widget.groupStateController,
                boardStateController: widget.boardStateController,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15, right: LIST_GAP),
                    width: widget.groupConstraints.maxWidth,
                    decoration: widget.groupDecoration ??
                        DefaultStyles.groupDecoration(),

                    ///If the current draggable is [this] group and it is being dragged over the current group, then animate.
                    child: InkWell(
                      onLongPress: () => ref
                          .read(widget.groupStateController)
                          .onGroupLongPress(
                            boardState: ref.read(widget.boardStateController),
                            groupIndex: widget.groupIndex,
                            context: context,
                            setState: () => setState(() {}),
                            footer: widget.footer,
                            header: widget.header,
                          ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// This builds the header of the group.
                          /// If the [GroupHeaderBuilder] is not provided, then it uses the default header.
                          _buildHeader(context, group),

                          /// This builds the body of the group.
                          /// This renders the list of items in the group.
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemCount: group.items.length,
                              itemBuilder: (ctx, index) {
                                return GroupItem(
                                  boardState: widget.boardStateController,
                                  boardGroupState: widget.groupStateController,
                                  groupItemState:
                                      widget.groupItemStateController,
                                  itemIndex: index,
                                  groupIndex: widget.groupIndex,
                                );
                              },
                            ),
                          ),

                          /// This builds the footer of the group.
                          /// If the [GroupFooterBuilder] is not provided, then it uses the default footer.
                          _buildFooter(context, group),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, IKanbanBoardGroup group) {
    return widget.header != null
        ? widget.header!(context, group.id)
        : DefaultStyles.groupHeader(
            group: group, onOperationSelect: onOperationSelect);
  }

  Widget _buildFooter(BuildContext context, IKanbanBoardGroup group) {
    return widget.footer != null
        ? widget.footer!(context, group.id)
        : DefaultStyles.groupFooter(
            onAddNewGroup: () =>
                {onOperationSelect(GroupOperationType.addItem)});
  }

  void _scrollToMax() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      return;
    }
    await _scrollController.animateTo(
      _scrollController.position.pixels +
          _scrollController.position.extentAfter,
      duration: Duration(
          milliseconds: (int.parse(_scrollController.position.extentAfter
              .toString()
              .substring(0, 3)
              .split('.')
              .first))),
      curve: Curves.linear,
    );
    _scrollToMax();
  }

  void scrollToMin() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      return;
    }
    log(_scrollController.position.extentBefore.toString());
    await _scrollController.animateTo(
      _scrollController.position.pixels -
          _scrollController.position.extentBefore,
      duration: Duration(
          milliseconds: (int.parse(_scrollController.position.extentBefore
              .toString()
              .substring(0, 3)
              .split('.')
              .first))),
      curve: Curves.linear,
    );
    scrollToMin();
  }
}

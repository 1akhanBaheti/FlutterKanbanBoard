import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/constants/constants.dart';
import 'package:kanban_board/src/constants/widget_styles.dart';
import 'package:kanban_board/src/board.dart';
import 'package:kanban_board/src/controllers/index.dart';
import 'package:kanban_board/src/widgets/group-item/group_item.dart';

class BoardGroup extends ConsumerStatefulWidget {
  const BoardGroup(
      {required this.boardStateController,
      required this.groupIndex,
      required this.groupConstraints,
      required this.groupDecoration,
      required this.itemBuilder,
      required this.groupItemStateContoller,
      required this.groupStateController,
      this.footer,
      this.header,
      super.key});
  final int groupIndex;
  final ChangeNotifierProvider<BoardStateController> boardStateController;
  final ChangeNotifierProvider<GroupItemStateController>
      groupItemStateContoller;
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

  /// It is used to handle the operations on the group.
  /// It is called when an operation is selected on the group through default header popup menu.
  void onOperationSelect(GroupOperationType type) {
    log("Operation selected $type");
  }

  /// These functions are used to handle the move of the draggable item.
  /// Case:1
  void _handleMoveToEmptyGroup() {
    log("Move to empty group");
  }

  /// When the draggable item is moved from one group to another group, which is empty.
  /// Case:2
  /// When the draggable item is moved from one group to another group, which contains only one item.
  ///
  ///
  // void _addBoardGroupScrollListener() {
  //   final boardProv = ref.read(ProviderList.boardProvider);
  //   final boardListProv = ref.read(ProviderList.boardListProvider);
  //   for (var element in boardProv.board.lists) {
  //     // List Scroll Listener
  //     element.scrollController.addListener(() {
  //       if (boardListProv.scrolling) {
  //         if (boardListProv.scrollingDown) {
  //           boardProv.valueNotifier.value = Offset(
  //               boardProv.valueNotifier.value.dx,
  //               boardProv.valueNotifier.value.dy + 0.00001);
  //         } else {
  //           boardProv.valueNotifier.value = Offset(
  //               boardProv.valueNotifier.value.dx,
  //               boardProv.valueNotifier.value.dy + 0.00001);
  //         }
  //       }
  //     });
  //   }
  // }

  @override
  void initState() {
    _scrollController = ref
        .read(widget.boardStateController)
        .groups[widget.groupIndex]
        .scrollController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.read(widget.boardStateController);
    final group = ref.watch(widget.boardStateController
        .select((value) => value.groups[widget.groupIndex]));
    final draggingState = ref.read(widget.boardStateController).draggingState;

    return ValueListenableBuilder(
      key: group.key,
      valueListenable: draggingState.feedbackOffset,
      builder: (context, draggableOffset, b) {
        if (draggingState.draggableType == DraggableType.item) {
          var dragStartIndex = draggingState.dragStartIndex;
          var dragStartGroupIndex = draggingState.dragStartGroupIndex;
          var box = context.findRenderObject();
          var groupRenderBox = group.key.currentContext!.findRenderObject();
          if (box == null || groupRenderBox == null) return b!;
          box = box as RenderBox;
          groupRenderBox = groupRenderBox as RenderBox;
          group.position =
              Offset(boardState.boardOffset.dx, boardState.boardOffset.dy);

          if (((draggingState.feedbackSize.width * 0.6) + draggableOffset.dx >
                  group.position!.dx) &&
              ((group.position!.dx + group.size.width >
                  draggingState.feedbackSize.width + draggableOffset.dx)) &&
              (draggingState.currentGroupIndex != widget.groupIndex)) {
            // print("RIGHT ->");
            // print(prov.board.lists[widget.index].items.length);
            // CASE: WHEN ELEMENT IS DRAGGED RIGHT SIDE AND LIST HAVE NO ELEMENT IN IT //
            if (group.items.isEmpty) {
              log("LIST 0 RIGHT");
              group.items.add(IKanbanBoardGroupItem(
                  key: GlobalKey(),
                  id: 'system-added-placeholder',
                  index: 0,
                  setState: () => {},
                  ghost: Container(
                    height: 100,
                    width: 200,
                    color: Colors.amber,
                  ),
                  addedBySystem: true,
                  groupIndex: widget.groupIndex));

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                boardState.groups[draggingState.currentGroupIndex]
                    .items[draggingState.currentIndex]
                  ..itemWidget = boardState
                      .groups[draggingState.currentGroupIndex]
                      .items[draggingState.currentIndex]
                      .ghost
                  ..setState();
                if (boardState.groups[draggingState.currentGroupIndex]
                        .items[draggingState.currentIndex].addedBySystem ==
                    true) {
                  boardState.groups[draggingState.currentGroupIndex].items
                      .removeAt(0);
                  log("ITEM REMOVED");
                  boardState
                      .groups[draggingState.currentGroupIndex].setState();
                }
                draggingState.currentIndex = 0;
                draggingState.currentGroupIndex = widget.groupIndex;
                setState(() {});
              });
            }
            // CASE WHEN LIST HAVE ONLY ONE ITEM AND IT IS PICKED, SO NOW IT IS HIDDEN, ITS SIZE IS 0 , SO WE NEED TO HANDLE IT EXPLICITLY  //
            else if (group.items.length == 1 &&
                draggingState.dragStartIndex == 0 &&
                draggingState.dragStartGroupIndex == widget.groupIndex) {
              // print("RIGHT LENGTH == 1");
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (boardState.groups[dragStartGroupIndex].items[dragStartIndex]
                        .addedBySystem ==
                    true) {
                  boardState.groups[dragStartGroupIndex].items
                      .removeAt(dragStartIndex);
                  boardState.groups[dragStartGroupIndex].setState();
                } else {
                  boardState.groups[draggingState.currentGroupIndex]
                      .items[draggingState.currentIndex]
                    ..updateWith(
                        itemWidget: boardState
                            .groups[draggingState.currentGroupIndex]
                            .items[draggingState.currentIndex]
                            .ghost,
                        placeHolderAt: PlaceHolderAt.none)
                    ..setState();
                }
                boardState.draggingState.currentIndex = 0;
                boardState.draggingState.currentGroupIndex = widget.groupIndex;
                // log("UPDATED | ITEM= ${widget.itemIndex} | LIST= ${widget.listIndex}");
                boardState.groups[draggingState.currentGroupIndex]
                    .items[draggingState.currentIndex]
                    .setState();
              });
            }
          } else if (((draggingState.feedbackSize.width * 0.6) +
                      draggableOffset.dx <
                  group.position!.dx + group.size.width) &&
              ((group.position!.dx + group.size.width <
                  draggingState.feedbackSize.width + draggableOffset.dx)) &&
              (draggingState.currentGroupIndex != widget.groupIndex)) {
            if (group.items.isEmpty) {
              //  print("LIST 0 LEFT");

              group.items.add(IKanbanBoardGroupItem(
                  key: GlobalKey(),
                  id: 'system-added-placeholder',
                  index: 0,
                  setState: () => {},
                  ghost: Container(
                    height: 100,
                    width: 200,
                    color: Colors.amber,
                  ),
                  addedBySystem: true,
                  groupIndex: widget.groupIndex));

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                boardState.groups[draggingState.currentGroupIndex]
                        .items[draggingState.currentIndex].itemWidget =
                    boardState.groups[draggingState.currentGroupIndex]
                        .items[draggingState.currentIndex].ghost;
                boardState.groups[draggingState.currentGroupIndex]
                    .items[draggingState.currentIndex]
                    .setState();

                if (boardState.groups[draggingState.currentGroupIndex]
                        .items[draggingState.currentIndex].addedBySystem ==
                    true) {
                  boardState.groups[draggingState.currentGroupIndex].items
                      .removeAt(0);
                  log("ITEM REMOVED");
                  boardState.groups[draggingState.currentGroupIndex].setState();
                }
                draggingState.currentIndex = 0;
                draggingState.currentGroupIndex = widget.groupIndex;
                setState(() {});
              });
            }
            // CASE: WHEN LIST CONTAINS ONLY ONE ITEM, AND WHICH IS THE FIRST ITEM DRAGGED DURING A PARTICULAR SESSION, WHICH IS CURRENTLY HIDDEN //

            else if (group.items.length == 1 &&
                dragStartIndex == 0 &&
                dragStartGroupIndex == widget.groupIndex) {
              // print("LEFT LENGTH == 1");
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                // CASE : IF PREVIOUSLY PLACEHOLDER IS ADDED IN EMPTY LIST THEN EXPLICITLY REMOVE THAT PLACEHOLDER, AND MAKE THAT LIST EMPTY AGAIN //
                if (boardState.groups[dragStartGroupIndex].items[dragStartIndex]
                        .addedBySystem ==
                    true) {
                  boardState.groups[dragStartGroupIndex].items
                      .removeAt(dragStartIndex);
                  boardState.groups[dragStartGroupIndex].setState();
                } else {
                  boardState.groups[dragStartGroupIndex].items[dragStartIndex]
                      .placeHolderAt = PlaceHolderAt.none;

                  boardState.groups[dragStartGroupIndex].items[dragStartIndex]
                          .itemWidget =
                      boardState.groups[dragStartGroupIndex]
                          .items[dragStartIndex].ghost;

                  boardState.groups[dragStartGroupIndex].items[dragStartIndex]
                      .setState();
                }

                // Placeholder is updated at current position //
                draggingState.currentIndex = 0;
                draggingState.currentGroupIndex = widget.groupIndex;
                // log("UPDATED | ITEM= ${widget.itemIndex} | LIST= ${widget.listIndex}");
                boardState.groups[draggingState.currentGroupIndex]
                    .items[draggingState.currentIndex]
                    .setState();
              });
            }
          }
        }
        return b!;
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 15, right: LIST_GAP),
          width: widget.groupConstraints.maxWidth,
          decoration: widget.groupDecoration ?? DefaultStyles.groupDecoration(),

          ///If the current draggable is [this] group and it is being dragged over the current group, then animate.
          child: draggingState.draggableType == DraggableType.group &&
                  draggingState.currentGroupIndex == widget.groupIndex
              ? TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Opacity(
                      opacity: 0.4, child: draggingState.draggingWidget))
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  /// This builds the header of the group.
                  /// If the [GroupHeaderBuilder] is not provided, then it uses the default header.
                  _buildHeader(context, group),

                  /// This builds the body of the group.
                  /// This renders the list of items in the group.
                  Flexible(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: group.items.length,
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        return GroupItem(
                          boardState: widget.boardStateController,
                          groupItemState: widget.groupItemStateContoller,
                          itemIndex: index,
                          groupIndex: widget.groupIndex,
                        );
                      },
                    ),
                  ),

                  /// This builds the footer of the group.
                  /// If the [GroupFooterBuilder] is not provided, then it uses the default footer.
                  _buildFooter(context, group),
                ]),
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

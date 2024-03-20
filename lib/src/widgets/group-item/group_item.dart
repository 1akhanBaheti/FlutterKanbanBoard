import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/controllers/board_state_controller.dart';
import 'package:kanban_board/src/controllers/group_item_state_controller.dart';
import 'package:kanban_board/src/controllers/states/draggable_state.dart';

class GroupItem extends ConsumerStatefulWidget {
  const GroupItem({
    required this.itemIndex,
    required this.groupIndex,
    required this.boardState,
    required this.groupItemState,
    super.key,
  });
  final int itemIndex;
  final int groupIndex;
  final ChangeNotifierProvider<BoardStateController> boardState;
  final ChangeNotifierProvider<GroupItemStateController> groupItemState;
  @override
  ConsumerState<GroupItem> createState() => _GroupItemState();
}

class _GroupItemState extends ConsumerState<GroupItem> {
  @override
  Widget build(BuildContext context) {
    // log("BUILDED ${widget.itemIndex}");
    final itemState = ref.read(widget.groupItemState);
    final boardState = ref.read(widget.boardState);
    final draggingState = boardState.draggingState;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      itemState.computeItemPositionSize(
          groupIndex: widget.groupIndex,
          itemIndex: widget.itemIndex,
          context: context,
          setstate: () => {setState(() {})});
    });
    return ValueListenableBuilder(
        valueListenable: boardState.draggingState.feedbackOffset,
        builder: (ctx, a, b) {
          if (draggingState.draggableType == DraggableType.item) {
            final groups = boardState.groups;
            // item added by system in empty list, its widget/UI should not be manipulated on movements //
            if (groups[widget.groupIndex].items.isEmpty) return b!;

            // CALCULATE SIZE AND POSITION OF ITEM //
            if (itemState.calculateSizePosition(
                groupIndex: widget.groupIndex, itemIndex: widget.itemIndex)) {
              return b!;
            }

            // IF ITEM IS LAST ITEM OF LIST, DIFFERENT APPROACH IS USED //

            // if (cardProv.isLastItemDragged(
            //     listIndex: widget.listIndex, itemIndex: widget.itemIndex)) {
            //   // log("LAST ELEMENT DRAGGED");
            //   return b!;
            // }

            // DO NOT COMPARE ANYTHING WITH DRAGGED ITEM, IT WILL CAUSE ERRORS BECUSE ITS HIDDEN //
            if ((draggingState.dragStartIndex == widget.itemIndex &&
                draggingState.dragStartGroupIndex == widget.groupIndex)) {
              return b!;
            }

            // if (widget.itemIndex - 1 >= 0 &&
            //     prov.board.lists[widget.listIndex].items[widget.itemIndex - 1]
            //             .containsPlaceholder ==
            //         true) {
            // //  log("FOR ${widget.listIndex} ${widget.itemIndex}");
            //   prov.board.lists[widget.listIndex].items[widget.itemIndex].y =
            //       prov.board.lists[widget.listIndex].items[widget.itemIndex]
            //               .y! -
            //           prov.board.lists[widget.listIndex].items[widget.itemIndex-1].actualSize!.height;
            // }

            if (itemState.getYAxisCondition(
                groupIndex: widget.groupIndex, itemIndex: widget.itemIndex)) {
              itemState.checkForYAxisMovement(
                  groupIndex: widget.groupIndex, itemIndex: widget.itemIndex);
            } else if (itemState.getXAxisCondition(
                groupIndex: widget.groupIndex, itemIndex: widget.itemIndex)) {
              itemState.checkForXAxisMovement(
                  groupIndex: widget.groupIndex, itemIndex: widget.itemIndex);
            }
          }
          return b!;
        },
        child: GestureDetector(
            key: boardState
                .groups[widget.groupIndex].items[widget.itemIndex].key,
            onLongPress: () {
              itemState.onLongPressItem(
                  groupIndex: widget.groupIndex,
                  itemIndex: widget.itemIndex,
                  context: context,
                  setsate: () => {setState(() {})});
            },
            child: draggingState.draggableType == DraggableType.item &&
                    draggingState.currentIndex == widget.itemIndex &&
                    draggingState.dragStartIndex == widget.itemIndex &&
                    draggingState.currentGroupIndex == widget.groupIndex &&
                    draggingState.dragStartGroupIndex == widget.groupIndex
                ? Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    width: draggingState.feedbackSize.width,
                    height: draggingState.feedbackSize.height,
                  )
                : itemState.isCurrentElementDragged(
                        groupIndex: widget.groupIndex,
                        itemIndex: widget.itemIndex)
                    ? Container()
                    : boardState.groups[widget.groupIndex]
                                .items[widget.itemIndex].placeHolderAt !=
                            PlaceHolderAt.none
                        ? boardState.groups[widget.groupIndex]
                            .items[widget.itemIndex].ghost
                        : Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            width: boardState.groups[widget.groupIndex]
                                .items[widget.itemIndex].size.width,
                            child: boardState.groups[widget.groupIndex]
                                .items[widget.itemIndex].itemWidget,
                          )));
  }
}

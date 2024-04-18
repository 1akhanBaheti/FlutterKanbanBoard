import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/controllers/board_state_controller.dart';
import 'package:kanban_board/src/controllers/group_item_state_controller.dart';
import 'package:kanban_board/src/controllers/group_state_controller.dart';
import 'package:kanban_board/src/controllers/states/draggable_state.dart';

class GroupItem extends ConsumerStatefulWidget {
  const GroupItem({
    required this.itemIndex,
    required this.groupIndex,
    required this.boardState,
    required this.boardGroupState,
    required this.groupItemState,
    super.key,
  });
  final int itemIndex;
  final int groupIndex;
  final ChangeNotifierProvider<BoardStateController> boardState;
  final ChangeNotifierProvider<GroupStateController> boardGroupState;
  final ChangeNotifierProvider<GroupItemStateController> groupItemState;
  @override
  ConsumerState<GroupItem> createState() => _GroupItemState();
}

class _GroupItemState extends ConsumerState<GroupItem>
    with TickerProviderStateMixin {
  late AnimationController? _animationController;

  @override
  void initState() {
    final groupItem = ref
        .read(widget.boardState)
        .groups[widget.groupIndex]
        .items[widget.itemIndex];

    groupItem.animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animationController = groupItem.animationController;

    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.read(widget.groupItemState);
    final boardState = ref.read(widget.boardState);
    final draggingState = boardState.draggingState;
    final groupItem =
        boardState.groups[widget.groupIndex].items[widget.itemIndex];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      itemState.computeItemPositionSize(
          groupIndex: widget.groupIndex,
          itemIndex: widget.itemIndex,
          context: context,
          setstate: () => {setState(() {})});
    });
    return ValueListenableBuilder(
        key: boardState.groups[widget.groupIndex].items[widget.itemIndex].key,
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

            // DO NOT COMPARE ANYTHING WITH DRAGGED ITEM, IT WILL CAUSE ERRORS BECUSE ITS HIDDEN //
            if ((draggingState.dragStartIndex == widget.itemIndex &&
                draggingState.dragStartGroupIndex == widget.groupIndex)) {
              return b!;
            }

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
                    : groupItem.ghost));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/constants/constants.dart';
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
        setState: () => setState(() {}),
      );
    });
    return ValueListenableBuilder(
      key: boardState.groups[widget.groupIndex].items[widget.itemIndex].key,
      valueListenable: boardState.draggingState.feedbackOffset,
      builder: (ctx, offset, child) {
        if (draggingState.draggableType == DraggableType.item) {
          final groups = boardState.groups;
          // item added by system in empty list, its widget/UI should not be manipulated on movements //
          if (groups[widget.groupIndex].items.isEmpty) return child!;

          // CALCULATE SIZE AND POSITION OF ITEM //
          if (itemState.calculateSizePosition(
              groupIndex: widget.groupIndex, itemIndex: widget.itemIndex)) {
            return child!;
          }

          // DO NOT COMPARE ANYTHING WITH DRAGGED ITEM, IT WILL CAUSE ERRORS BECAUSE ITS HIDDEN //
          if ((draggingState.dragStartIndex == widget.itemIndex &&
              draggingState.dragStartGroupIndex == widget.groupIndex)) {
            return child!;
          }

          if (itemState.getYAxisCondition(
              groupIndex: widget.groupIndex, itemIndex: widget.itemIndex)) {
            itemState.handleSameGroupMove(
                groupIndex: widget.groupIndex, itemIndex: widget.itemIndex);
          } else if (itemState.getXAxisCondition(
              groupIndex: widget.groupIndex, itemIndex: widget.itemIndex)) {
            itemState.handleDiffGroupMove(
                groupIndex: widget.groupIndex, itemIndex: widget.itemIndex);
          }
        }
        return child!;
      },
      child: GestureDetector(
        onLongPress: () {
          itemState.onLongPressItem(
              groupIndex: widget.groupIndex,
              itemIndex: widget.itemIndex,
              context: context,
              setState: () => {setState(() {})});
        },
        child:
            // if item which is being dragged is same as current item, show feedback container
            draggingState.draggableType == DraggableType.item &&
                    draggingState.currentIndex == widget.itemIndex &&
                    draggingState.dragStartIndex == widget.itemIndex &&
                    draggingState.currentGroupIndex == widget.groupIndex &&
                    draggingState.dragStartGroupIndex == widget.groupIndex
                ? Container(
                    margin: const EdgeInsets.only(bottom: CARD_GAP),
                    width: draggingState.feedbackSize.width,
                    height: draggingState.feedbackSize.height,
                    child: boardState.itemGhost,
                  )
                : itemState.isCurrentElementDragged(
                    groupIndex: widget.groupIndex,
                    itemIndex: widget.itemIndex,
                  )
                    ? Container()
                    : Container(
                        margin: const EdgeInsets.only(bottom: CARD_GAP),
                        child: groupItem.ghost,
                      ),
      ),
    );
  }
}

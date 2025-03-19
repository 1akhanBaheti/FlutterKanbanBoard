import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:kanban_board/src/board.dart';
import 'package:kanban_board/src/controllers/board_state_controller.dart';
import 'package:kanban_board/src/constants/constants.dart';
import 'package:kanban_board/src/helpers/group_drag_coordinates_helper.dart';
import 'package:kanban_board/src/helpers/widget_detail.helper.dart';
import 'states/board_internal_states.dart';
import 'states/draggable_state.dart';

class GroupStateController extends ChangeNotifier {
  GroupStateController(this.boardState);
  final BoardStateController boardState;
  bool isScrolling = false;

  void setScrolling(bool value, {bool notify = false}) {
    isScrolling = value;
    if (notify) notifyListeners();
  }

  void calculateSizePosition(
      {required BoardStateController boardState,
      required int groupIndex,
      required BuildContext context,
      required VoidCallback setstate}) {
    final group = boardState.groups[groupIndex];
    var groupRenderbox = context.findRenderObject() as RenderBox;
    var position = groupRenderbox.localToGlobal(Offset.zero);
    group
      ..position = Offset(position.dx - boardState.boardOffset.dx,
          position.dy - boardState.boardOffset.dy)
      ..setState = setstate
      ..size =
          Size(groupRenderbox.size.width - LIST_GAP, groupRenderbox.size.height)
      ..actualSize = group.actualSize == Size.zero
          ? Size(
              groupRenderbox.size.width - LIST_GAP, groupRenderbox.size.height)
          : group.actualSize;
  }

  /// This method is called on the onDragEnd event of the draggable widget
  /// It is responsible for reordering the card in the board
  void onDragEnd({
    OnGroupMove? onGroupMove,
  }) {
    final groups = boardState.groups;
    final draggedState = boardState.draggingState;

    final currentGroup = groups[draggedState.currentGroupIndex];
    int resolvedDropIndex = currentGroup.placeHolderAt.isLeft
        ? draggedState.currentGroupIndex
        : draggedState.currentGroupIndex + 1;
    final groupToInsert =
        groups[draggedState.dragStartGroupIndex].copyWith(key: GlobalKey());

    groups.insert(resolvedDropIndex, groupToInsert);
    int indexToRemove = -1;
    if (draggedState.dragStartGroupIndex < resolvedDropIndex) {
      indexToRemove = draggedState.dragStartGroupIndex;
      resolvedDropIndex--;
    } else {
      indexToRemove = draggedState.dragStartGroupIndex + 1;
    }
    groups.removeAt(indexToRemove);

    /// Reset the placeholder of the groupItem.
    /// This is done to remove the placeholder from the groupItem.
    currentGroup.placeHolderAt = PlaceHolderAt.none;

    /// Call the onGroupMove callback if it is provided.
    onGroupMove?.call(
      draggedState.dragStartGroupIndex,
      resolvedDropIndex,
    );

    /// Reset the dragging state to its initial state.
    boardState.draggingState = DraggableState.initial(
      feedbackOffset: boardState.draggingState.feedbackOffset,
    );

    currentGroup.setState();
    groups[draggedState.dragStartGroupIndex].setState();
    // TODO: Move to different provider -- just because of draggingState
    boardState.notify();
  }

  void onGroupLongPress(
      {required BoardStateController boardState,
      required int groupIndex,
      required BuildContext context,
      required VoidCallback setState,
      GroupFooterBuilder? footer,
      GroupHeaderBuilder? header}) {
    for (final group in boardState.groups) {
      if (group.key.currentState == null || !group.key.currentState!.mounted) {
        break;
      }
      final itemRenderBox =
          group.key.currentState!.context.findRenderObject() as RenderBox;
      final position = itemRenderBox.localToGlobal(Offset.zero);
      group
        ..position = Offset(position.dx - boardState.boardOffset.dx + 10,
            position.dy - boardState.boardOffset.dy + 10)
        ..size = Size(
            itemRenderBox.size.width - LIST_GAP, itemRenderBox.size.height);
    }
    boardState.groups[groupIndex].setState = setState;
    boardState.draggingState.feedbackOffset.value =
        boardState.groups[groupIndex].position!;
    final group = boardState.groups[groupIndex];
    boardState.draggingState.updateWith(
      draggingWidget: WidgetHelper.getDraggingGroup(
        context: context,
        group: group,
        groupIndex: groupIndex,
        footer: footer,
        header: header,
      ),
      draggableType: DraggableType.group,
      feedbackSize: boardState.groups[groupIndex].size,
      dragStartGroupIndex: groupIndex,
      currentIndex: groupIndex,
      currentGroupIndex: groupIndex,
      dragStartIndex: groupIndex,
    );
    setState();
  }

  /// [handleItemDragOverGroup] handles the placement of the dragged item, when it is dragged over a group.
  /// It only handles two cases:
  /// 1. When the item is dragged over a empty group.
  /// 2. When the group from which the item is dragged gets empty || basically the only item in the group is dragged.
  void handleItemDragOverGroup(
    int groupIndex,
  ) {
    final draggingState = boardState.draggingState;
    final group = boardState.groups[groupIndex];
    if (!canItemDropOverGroup(groupIndex)) return;
    if (group.items.isNotEmpty &&
        !(group.items.length == 1 &&
            draggingState.dragStartGroupIndex == groupIndex &&
            draggingState.dragStartIndex == 0)) return;

    // print("HREE ${draggingState.dragStartGroupIndex} ${groupIndex} ${draggingState.dragStartGroupIndex == groupIndex}");
    if (group.items.isEmpty) {
      /// Add the placeholder directly to the group as item.
      group.items.add(
        IKanbanBoardGroupItem(
          key: GlobalKey(),
          //TODO: move this keys constant
          id: 'system-added-placeholder',
          index: 0,
          setState: () => {},
          placeHolderAt: PlaceHolderAt.none,
          ghost: Container(
            margin: const EdgeInsets.only(
              bottom: CARD_GAP,
            ),
            width: draggingState.feedbackSize.width,
            height: draggingState.feedbackSize.height,
            child: DottedBorder(
              child: const Center(
                  child: Text(
                "Drop your task here",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
            ),
          ),
          addedBySystem: true,
          groupIndex: groupIndex,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// Remove the placeholder from the previous group-item.
      final placeholderAttachedItem = boardState
          .groups[draggingState.currentGroupIndex]
          .items[draggingState.currentIndex];
      placeholderAttachedItem.placeHolderAt = PlaceHolderAt.none;

      /// If the last placeholder was added by the system as item in the group, then remove it.
      if (boardState.groups[draggingState.currentGroupIndex]
              .items[draggingState.currentIndex].addedBySystem ==
          true) {
        boardState.groups[draggingState.currentGroupIndex].items.removeAt(0);
        boardState.groups[draggingState.currentGroupIndex].setState();
      } else {
        placeholderAttachedItem.setState();
      }

      /// Update the dragging state.
      draggingState.currentIndex = 0;
      draggingState.currentGroupIndex = groupIndex;

      /// Rebuild the group.
      group.setState();
    });
  }

  void handleGroupDragOverGroup(int groupIndex) {
    final draggingState = boardState.draggingState;
    final groups = boardState.groups;
    final group = boardState.groups[groupIndex];
    final placeholderAt = canGroupDropOverGroup(groupIndex);
    if (placeholderAt == PlaceHolderAt.none ||
        group.animationController!.isAnimating) return;

    /// Remove the placeholder from the previous group-item.
    // wrapWithPlaceHolder(
    //     groupIndex: draggingState.currentGroupIndex, reset: true);
    groups[draggingState.currentGroupIndex].animationOffset = Offset(
        groups[draggingState.currentGroupIndex].placeHolderAt ==
                PlaceHolderAt.left
            ? -1
            : groups[draggingState.currentGroupIndex].placeHolderAt ==
                    PlaceHolderAt.right
                ? 1
                : 0,
        0);
    groups[draggingState.currentGroupIndex].placeHolderAt = PlaceHolderAt.none;

    // wrapWithPlaceHolder(groupIndex: groupIndex);
    groups[groupIndex].placeHolderAt = placeholderAt;

    groups[groupIndex].animationOffset = Offset(
        groups[groupIndex].placeHolderAt == PlaceHolderAt.left
            ? -1
            : groups[groupIndex].placeHolderAt == PlaceHolderAt.right
                ? 1
                : 0,
        0);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (groups[draggingState.currentGroupIndex]
          .animationController!
          .isAnimating) {
        groups[draggingState.currentGroupIndex].animationController!.fling();
      }
      groups[draggingState.currentGroupIndex].setState();
      draggingState.currentGroupIndex = groupIndex;
      groups[groupIndex].setState();
      if (group.animationController!.isCompleted) {
        group.animationController?.forward(from: -1.0);
      } else {
        group.animationController?.forward();
      }
    });
  }

  /// [canItemDropOverGroup] checks if the dragged item can be dropped on the group or not.
  /// It checks if the item is entering the group from the left or right side.
  PlaceHolderAt canGroupDropOverGroup(int groupIndex) {
    final draggingState = boardState.draggingState;
    final group = boardState.groups[groupIndex];
    final draggableOffset = draggingState.feedbackOffset.value;

    bool canDrop = false;
    PlaceHolderAt placeHolderAt = PlaceHolderAt.none;

    // Helper variables for position calculations
    final groupStartX = group.position!.dx;
    final groupWidth = group.size.width;
    final dragEndX = draggingState.feedbackSize.width + draggableOffset.dx;
    final dragStartX = draggableOffset.dx;

    // Check if placeholder already exists on left side
    if (group.placeHolderAt == PlaceHolderAt.left) {
      final isEnteringFromLeft = dragEndX > groupStartX + (groupWidth * 0.75) &&
          groupStartX < dragStartX;

      canDrop = isEnteringFromLeft;
      placeHolderAt = PlaceHolderAt.right;
    }
    // Check if placeholder already exists on right side
    else if (group.placeHolderAt == PlaceHolderAt.right) {
      final isEnteringFromRight =
          dragStartX < groupStartX + (group.actualSize.width * 0.5) &&
              groupStartX + groupWidth > dragEndX;

      canDrop = isEnteringFromRight;
      placeHolderAt = PlaceHolderAt.left;
    }
    // No existing placeholder, determine direction
    else {
      final isEnteringFromRight =
          dragStartX < groupStartX + (groupWidth * 0.4) &&
              groupStartX + group.actualSize.width < dragEndX;

      final isEnteringFromLeft = dragEndX >= groupStartX + (groupWidth * 0.5) &&
          dragStartX < groupStartX;

      canDrop = isEnteringFromLeft || isEnteringFromRight;

      if (isEnteringFromLeft) {
        placeHolderAt = PlaceHolderAt.right;
      } else if (isEnteringFromRight) {
        placeHolderAt = PlaceHolderAt.left;
      }
    }

    // Only allow drop if dragging between different groups
    if (canDrop && draggingState.dragStartGroupIndex != groupIndex) {
      return placeHolderAt;
    }
    return PlaceHolderAt.none;
  }

  /// [canItemDropOverGroup] checks if the dragged item can be dropped on the group or not.
  /// It checks if the item is entering the group from the left or right side.
  bool canItemDropOverGroup(int groupIndex) {
    final draggingState = boardState.draggingState;
    final group = boardState.groups[groupIndex];
    final canDrop = GroupDragCoordinatesHelper.canItemDropOverGroup(
      draggingState: draggingState,
      group: group,
    );

    /// For item to change group, it should not be in the same group.
    return canDrop && draggingState.currentGroupIndex != groupIndex;
  }
}

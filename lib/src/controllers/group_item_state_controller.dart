import 'package:flutter/material.dart';
import 'package:kanban_board/src/constants/constants.dart';
import 'controllers.dart';

class GroupItemStateController extends ChangeNotifier {
  GroupItemStateController(this.boardState);
  final BoardStateController boardState;
  TextEditingController newCardTextController = TextEditingController();

  /// [computeItemPositionSize] is used to compute the position and size of the groupItem.
  /// On each build of the groupItem, the position and size of the groupItem is computed.
  void computeItemPositionSize(
      {required int groupIndex,
      required int itemIndex,
      required BuildContext context,
      required VoidCallback setState,
      }) {
    final groupItem = boardState.groups[groupIndex].items[itemIndex];
    if (!context.mounted) return;
    final itemRenderBox = context.findRenderObject() as RenderBox;
    final location = itemRenderBox.localToGlobal(Offset.zero);
    groupItem.updateWith(
      setState: setState,
      position: Offset(location.dx - boardState.boardOffset.dx,
          location.dy - boardState.boardOffset.dy),
      size: groupItem.size == Size.zero
          ? Size(itemRenderBox.size.width, itemRenderBox.size.height - CARD_GAP)
          : null,
      // actual size should not be updated, as groupItem might contain placeholder widget.
    );

    /// useCase: when item is not in view, and on scrolling it comes in view, then rebuild the widget to update the position and size.
    /// to ensure key.currentContext is not null, for any widget that is in view.
    if (groupItem.key.currentContext == null ||
        !groupItem.key.currentContext!.mounted) {
      setState();
    }
  }

  /// This method is called on the [LongPress] event of the group-groupItem widget.
  /// It is responsible for setting the state of the dragged groupItem with updated position and size.
  void onLongPressItem({
    required int groupIndex,
    required int itemIndex,
    required BuildContext context,
    required VoidCallback setState,
  }) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;
    final box = context.findRenderObject() as RenderBox;
    final location = box.localToGlobal(Offset.zero);
    groupItem.updateWith(
      position: Offset(location.dx - boardState.boardOffset.dx,
          location.dy - boardState.boardOffset.dy),
      size: Size(box.size.width, box.size.height - CARD_GAP),
      actualSize: Size(box.size.width, box.size.height - CARD_GAP),
      setState: setState,
    );

    //If the groupItem is added by the system, then restrict the drag operation.
    if (groupItem.addedBySystem) return;

    draggingState.feedbackOffset.value = groupItem.position!;
    draggingState.updateWith(
      feedbackSize: groupItem.size,
      draggableType: DraggableType.item,
      dragStartIndex: itemIndex,
      dragStartGroupIndex: groupIndex,
      currentIndex: itemIndex,
      currentGroupIndex: groupIndex,
      draggingWidget: Opacity(
        opacity: 0.5,
        child: SizedBox(
          height: groupItem.size.height,
          width: groupItem.size.width,
          child: groupItem.itemWidget,
        ),
      ),
    );
    setState();
  }

  /// [resetItemWidget] is used to reset the placeholder widget of the groupItem.
  /// This is called whenever the groupItem is moved to a different position, to remove the placeholder from the last position.
  void resetItemWidget() {
    wrapWithPlaceHolder(
      groupIndex: boardState.draggingState.currentGroupIndex,
      itemIndex: boardState.draggingState.currentIndex,
      reset: true,
    );
    final groupItem = boardState
        .groups[boardState.draggingState.currentGroupIndex]
        .items[boardState.draggingState.currentIndex];
    groupItem.placeHolderAt = PlaceHolderAt.none;
  }

  /// [calculateSizePosition] is used to calculate the size and position of the groupItem.
  /// This is called on every move of dragging widget, to compute the position and size of the groupItem & group.
  /// This helps in further computation of the placeholder widget.
  bool calculateSizePosition({
    required int groupIndex,
    required int itemIndex,
  }) {
    final group = boardState.groups[groupIndex];
    var groupItem = group.items[itemIndex];

    /// This is used to check if the groupItem is in view or not.
    if (groupItem.key.currentContext == null ||
        group.key.currentContext == null ||
        !groupItem.key.currentContext!.mounted) {
      return true;
    }
    var itemRenderBox = groupItem.key.currentContext!.findRenderObject();
    var groupRenderBox = group.key.currentContext!.findRenderObject();
    if (itemRenderBox == null || groupRenderBox == null) return true;

    itemRenderBox = itemRenderBox as RenderBox;
    groupRenderBox = groupRenderBox as RenderBox;
    final position = itemRenderBox.localToGlobal(Offset.zero);

    // Update the size and position of the groupItem and group.
    groupItem.updateWith(
      size: itemRenderBox.size,
      actualSize: groupItem.actualSize == Size.zero ? itemRenderBox.size : null,
      position: Offset(position.dx - boardState.boardOffset.dx,
          position.dy - boardState.boardOffset.dy),
    );
    group.updateWith(
        position: Offset(
            groupRenderBox.localToGlobal(Offset.zero).dx -
                boardState.boardOffset.dx,
            groupRenderBox.localToGlobal(Offset.zero).dy -
                boardState.boardOffset.dy),
        size: Size(
            groupRenderBox.size.width - LIST_GAP, groupRenderBox.size.height));
    return false;
  }

  /// [wrapWithPlaceHolder] add/remove the placeholder widget to the groupItem.
  /// It wraps placeholder/actual-widget with respective animation.
  void wrapWithPlaceHolder(
      {required int groupIndex, required int itemIndex, bool reset = false}) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;

    // update the ghost widget with placeholder wrapped groupItem.
    groupItem.ghost = Column(
      children: [
        groupItem.placeHolderAt == PlaceHolderAt.top && !reset
            ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 2000),
                curve: Curves.ease,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Container(
                    margin: const EdgeInsets.only(bottom: CARD_GAP),
                    width: draggingState.feedbackSize.width,
                    height: draggingState.feedbackSize.height,
                    child: boardState.itemGhost),
              )
            : Container(),
        SlideTransition(
            position: Tween<Offset>(
                    begin: Offset(
                        0,
                        groupItem.placeHolderAt == PlaceHolderAt.bottom
                            ? 1
                            : groupItem.placeHolderAt == PlaceHolderAt.top
                                ? -1
                                : 0),
                    end: const Offset(0, 0))
                .animate(
              CurvedAnimation(
                parent: groupItem.animationController!,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
                margin: const EdgeInsets.only(top: 0),
                width: draggingState.feedbackSize.width,
                height: draggingState.feedbackSize.height,
                child: groupItem.itemWidget)),
        groupItem.placeHolderAt == PlaceHolderAt.bottom && !reset
            ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 2000),
                curve: Curves.ease,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Container(
                    margin: const EdgeInsets.only(top: CARD_GAP),
                    width: draggingState.feedbackSize.width,
                    height: draggingState.feedbackSize.height,
                    child: boardState.itemGhost),
              )
            : Container(),
      ],
    );
  }

  /// [isCurrentSystemItem] check's, if the current placeholder is added by the system.
  /// Placeholder is added by the system, when dragging widget drag over the empty group.
  /// It also removes the placeholder from the last position.
  /// [Returns] true, if the current item is added by the system, else false.
  bool isCurrentSystemItem({required int groupIndex, required int itemIndex}) {
    final draggingState = boardState.draggingState;
    final groups = boardState.groups;
    var groupItem = groups[groupIndex].items[itemIndex];
    if (groups[draggingState.currentGroupIndex]
        .items[draggingState.currentIndex]
        .addedBySystem) {
      groups[draggingState.currentGroupIndex].items = [];
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        groups[draggingState.currentGroupIndex].setState();
        draggingState.currentIndex = itemIndex;
        draggingState.currentGroupIndex = groupIndex;
        groupItem.setState();
      });

      return true;
    }
    return false;
  }

  void handleSameGroupMove({required int groupIndex, required int itemIndex}) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;
    bool willPlaceHolderAtBottom =
        _bottomPlaceHolderPossibility(groupIndex, itemIndex);
    if (getYAxisCondition(groupIndex: groupIndex, itemIndex: itemIndex)) {
      // Reset the placeholder from the last position.
      resetItemWidget();

      // Set the placeholder at the top/bottom of the groupItem.
      groupItem.placeHolderAt =
          willPlaceHolderAtBottom ? PlaceHolderAt.bottom : PlaceHolderAt.top;

      // Wrap the groupItem with placeholder, to show the placeholder at the top/bottom of the groupItem.
      if ((!groupItem.addedBySystem)) {
        wrapWithPlaceHolder(
          groupIndex: groupIndex,
          itemIndex: itemIndex,
        );
      }
      // Check if the last placeholder is added by the system, so there should not be any manipulation with the same column y-axis widgets.
      if (isCurrentSystemItem(groupIndex: groupIndex, itemIndex: itemIndex)) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        /// Check if the groupItem is in view or not.
        if (groups[draggingState.currentGroupIndex]
                    .items[draggingState.currentIndex]
                    .key
                    .currentContext ==
                null ||
            !groups[draggingState.currentGroupIndex]
                .items[draggingState.currentIndex]
                .key
                .currentContext!
                .mounted) return;

        // Reset the placeholder from the last position.
        if (itemIndex != draggingState.currentIndex &&
            draggingState.currentGroupIndex != groupIndex) {
          resetItemWidget();
        }
        // If the current item is animating, fasten the animation.
        if (groups[draggingState.currentGroupIndex]
            .items[draggingState.currentIndex]
            .animationController!
            .isAnimating) {
          groups[draggingState.currentGroupIndex]
              .items[draggingState.currentIndex]
              .animationController!
              .fling();
        }
        // rebuild the last groupItem with removed placeholder.
        groups[draggingState.currentGroupIndex]
            .items[draggingState.currentIndex]
            .setState();

        // Update the current index and current group index.
        draggingState.currentIndex = itemIndex;
        draggingState.currentGroupIndex = groupIndex;
        // rebuild the current groupItem with added placeholder.
        groupItem.setState();

        // Start the animation of the groupItem.
        if (groupItem.animationController!.isCompleted) {
          groupItem.animationController?.forward(from: -1.0);
        } else {
          groupItem.animationController?.forward();
        }
      });
    }
  }

  bool _topPlaceHolderPossibility(int groupIndex, int itemIndex) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;

    var willPlaceHolderAtTop = groupItem.placeHolderAt == PlaceHolderAt.bottom
        ? (draggingState.feedbackOffset.value.dy <
            groupItem.position!.dy + (groupItem.actualSize.height * 0.5))
        : ((draggingState.feedbackOffset.value.dy <=
                groupItem.position!.dy + (groupItem.actualSize.height * 0.5)) &&
            (draggingState.feedbackSize.height +
                    draggingState.feedbackOffset.value.dy >
                groupItem.position!.dy + (groupItem.actualSize.height)));

    return willPlaceHolderAtTop &&
        draggingState.axisDirection == AxisDirection.up &&
        groupItem.placeHolderAt != PlaceHolderAt.top &&
        draggingState.currentGroupIndex == groupIndex &&
        groupItem.addedBySystem != true;
  }

  /// This method checks if the current groupItem can be combined with placeholder at bottom of it.
  bool _bottomPlaceHolderPossibility(int groupIndex, int itemIndex) {
    final groups = boardState.groups;
    var groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;

    /// There are two cases for the bottom placeholder possibility:

    var willPlaceHolderAtBottom =

        /// 1. If there already exists a placeholder at the top of the groupItem:
        /// In this case, the bottom placeholder will be placed only, if the draggable have crossed 80% height of the current item.
        groupItem.placeHolderAt == PlaceHolderAt.top
            ? (draggingState.feedbackSize.height +
                    draggingState.feedbackOffset.value.dy >=
                groupItem.position!.dy + (groupItem.size.height * 0.75))

            /// 2. If there is no placeholder attached to the groupItem:
            /// In this case, the bottom placeholder will be placed only, if the draggable have crossed 50% height of the current item.
            /// and the [draggable-top] is above the [groupItem-top].
            /// This is to ensure that the placeholder should be attached to current item only, cause all validation is done on the basis of current item [size] [position].
            : ((draggingState.feedbackSize.height +
                        draggingState.feedbackOffset.value.dy >=
                    groupItem.position!.dy +
                        (groupItem.actualSize.height * 0.5)) &&
                (draggingState.feedbackOffset.value.dy <
                    groupItem.position!.dy));

    // if (willPlaceHolderAtBottom) {
    //   log("${draggingState.feedbackSize.height} + ${draggingState.feedbackOffset.value.dy} >= ${groupItem.position!.dy} + ${groupItem.actualSize.height * 0.8}");
    // }

    /// This is the last validation to check if the placeholder should be attached to the current item.
    return willPlaceHolderAtBottom &&
        draggingState.axisDirection == AxisDirection.down &&

        /// There should not exist bottom placeholder to the current item, if the current item is added by the system.
        groupItem.placeHolderAt != PlaceHolderAt.bottom &&

        /// The selected item for placeholder should be from the same group that is being dragged.
        draggingState.currentGroupIndex == groupIndex &&

        /// The current item should not be added by the system.
        groupItem.addedBySystem != true;
  }

  bool getYAxisCondition({required int groupIndex, required int itemIndex}) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;

    var right = (draggingState.feedbackOffset.value.dx <=
            groups[groupIndex].position!.dx +
                (groups[groupIndex].size.width * 0.4)) &&
        ((groups[groupIndex].position!.dx + groups[groupIndex].size.width <=
            draggingState.feedbackSize.width +
                draggingState.feedbackOffset.value.dx));

    var left = ((draggingState.feedbackOffset.value.dx <=
            groups[groupIndex].position!.dx) &&
        (draggingState.feedbackSize.width +
                draggingState.feedbackOffset.value.dx >=
            groups[groupIndex].position!.dx +
                (groups[groupIndex].size.width * 0.6)));

    bool value = (_topPlaceHolderPossibility(groupIndex, itemIndex) ||
            _bottomPlaceHolderPossibility(groupIndex, itemIndex)) &&
        (right || left) &&
        draggingState.currentGroupIndex == groupIndex;
    return value && groupItem.addedBySystem != true;
  }

  bool getXAxisCondition({required int groupIndex, required int itemIndex}) {
    final groups = boardState.groups;
    final draggingState = boardState.draggingState;
    var right = (draggingState.feedbackOffset.value.dx <=
            groups[groupIndex].position!.dx +
                (groups[groupIndex].size.width * 0.4)) &&
        ((groups[groupIndex].position!.dx + groups[groupIndex].size.width <
            draggingState.feedbackSize.width +
                draggingState.feedbackOffset.value.dx));

    var left = ((draggingState.feedbackOffset.value.dx <
            groups[groupIndex].position!.dx) &&
        (draggingState.feedbackSize.width +
                draggingState.feedbackOffset.value.dx >=
            groups[groupIndex].position!.dx +
                (groups[groupIndex].size.width * 0.6)));
    return (left || right) && draggingState.currentGroupIndex != groupIndex;
  }

  void handleDiffGroupMove({required int groupIndex, required int itemIndex}) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;

    var canReplaceCurrent =
        ((draggingState.feedbackOffset.value.dy >= groupItem.position!.dy) &&
            (groupItem.size.height + groupItem.position!.dy >
                draggingState.feedbackOffset.value.dy +
                    (draggingState.feedbackSize.height / 2)));
    var willPlaceHolderAtBottom =
        (itemIndex == groups[groupIndex].items.length - 1 &&
            ((draggingState.feedbackSize.height * 0.6) +
                    draggingState.feedbackOffset.value.dy >
                groupItem.position!.dy + groupItem.size.height));

    if (canReplaceCurrent || willPlaceHolderAtBottom) {
      resetItemWidget();
      groupItem.placeHolderAt =
          willPlaceHolderAtBottom ? PlaceHolderAt.bottom : PlaceHolderAt.top;

      wrapWithPlaceHolder(groupIndex: groupIndex, itemIndex: itemIndex);
      if (isCurrentSystemItem(groupIndex: groupIndex, itemIndex: itemIndex)) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (itemIndex != draggingState.currentIndex &&
            draggingState.currentGroupIndex != groupIndex) {
          resetItemWidget();
        }
        final animationController = groups[draggingState.currentGroupIndex]
            .items[draggingState.currentIndex]
            .animationController;
        if (animationController?.isAnimating == true) {
          animationController!.fling();
        }
        groups[draggingState.currentGroupIndex]
            .items[draggingState.currentIndex]
            .setState();

        draggingState.currentIndex = itemIndex;
        draggingState.currentGroupIndex = groupIndex;

        groupItem.setState();
        if (groupItem.animationController!.isCompleted) {
          groupItem.animationController?.forward(from: -1.0);
        } else {
          groupItem.animationController?.forward();
        }
      });
    }
  }

  bool isCurrentElementDragged(
      {required int groupIndex, required int itemIndex}) {
    final draggingState = boardState.draggingState;

    return draggingState.draggableType == DraggableType.item &&
        draggingState.dragStartIndex == itemIndex &&
        draggingState.dragStartGroupIndex == groupIndex;
  }

  void updateCardPlaceholder({
    required int groupIndex,
    required int itemIndex,
    bool update = false,
  }) {
    resetItemWidget();
    final groupItem = boardState.groups[groupIndex].items[itemIndex];
    if (update) groupItem.setState();
  }

  /// This method is called on the onDragEnd event of the draggable widget
  /// It is responsible for reordering the card in the board
  void onDragEnd() {
    final groups = boardState.groups;
    final draggedState = boardState.draggingState;

    IKanbanBoardGroup group = boardState.groups[draggedState.currentGroupIndex];
    IKanbanBoardGroupItem groupItem = group.items[draggedState.currentIndex];

    /// If the card is dropped in the same group.
    if (draggedState.dragStartGroupIndex == draggedState.currentGroupIndex) {
      final resolvedDropIndex = groupItem.placeHolderAt.isTop
          ? draggedState.currentIndex
          : draggedState.currentIndex + 1;
      updateCardPlaceholder(
        groupIndex: draggedState.currentGroupIndex,
        itemIndex: draggedState.currentIndex,
        update: true,
      );

      /// Remove the groupItem from the index from where it was dragged, and insert it at the current index.
      final itemToInsert = groups[draggedState.dragStartGroupIndex]
          .items
          .elementAt(draggedState.dragStartIndex)
          .copyWith(key: GlobalKey());
      group.items.insert(resolvedDropIndex, itemToInsert);
      // If dragged item is before the resolved drop index, that means after inserting the dragged item, it's old index will not be affected.
      // So we can remove the item at the old index.
      // If dragged item is after the resolved drop index, that means after inserting the dragged item, it's old index will be affected.
      // So we need to remove the item at the old index + 1.
      group.items.removeAt(
        draggedState.dragStartIndex < resolvedDropIndex
            ? draggedState.dragStartIndex
            : draggedState.dragStartIndex + 1,
      );
    }

    /// If the card is dropped in a different group.
    else {
      if (groupItem.addedBySystem) {
        group.items.removeAt(draggedState.currentIndex);
        group.items.insert(
            draggedState.currentIndex,
            groups[draggedState.dragStartGroupIndex]
                .items
                .removeAt(draggedState.dragStartIndex));
      }

      /// If the placeholder is at the bottom of any groupItem, insert the groupItem at the current index + 1.
      /// This is because the groupItem at the current index will be shifted to the previous index.
      else if (groupItem.placeHolderAt == PlaceHolderAt.bottom) {
        updateCardPlaceholder(
          groupIndex: draggedState.currentGroupIndex,
          itemIndex: draggedState.currentIndex,
          update: true,
        );
        group.items.insert(
            draggedState.currentIndex + 1,
            groups[draggedState.dragStartGroupIndex]
                .items
                .removeAt(draggedState.dragStartIndex));
      } else {
        updateCardPlaceholder(
          groupIndex: draggedState.currentGroupIndex,
          itemIndex: draggedState.currentIndex,
          update: true,
        );

        /// If the placeholder is at the top of any groupItem, insert the groupItem at the current index.
        /// This is because the groupItem at the current index will be shifted to the next index.
        group.items.insert(
            draggedState.currentIndex,
            groups[draggedState.dragStartGroupIndex]
                .items
                .removeAt(draggedState.dragStartIndex));
      }
    }

    /// Reset the placeholder of the groupItem.
    /// This is done to remove the placeholder from the groupItem.

    /// Rebuild the current group to which the groupItem is dropped.
    groups[draggedState.currentGroupIndex].setState();
    // Rebuild the group from which the groupItem was dragged.
    groups[draggedState.dragStartGroupIndex].setState();

    /// Reset the dragging state to its initial state.
    boardState.draggingState = DraggableState.initial(
      feedbackOffset: boardState.draggingState.feedbackOffset,
    );

    boardState.notify();
  }
}

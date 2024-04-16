import 'dart:developer';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:kanban_board/src/constants/constants.dart';

import 'index.dart';

class GroupItemStateController extends ChangeNotifier {
  GroupItemStateController(this.boardState);
  // final ChangeNotifierProviderRef<ListItemProvider> ref;
  final BoardStateController boardState;
  TextEditingController newCardTextController = TextEditingController();

  void computeItemPositionSize(
      {required int groupIndex,
      required int itemIndex,
      required BuildContext context,
      required VoidCallback setstate}) {
    final groupItem = boardState.groups[groupIndex].items[itemIndex];
    if (!context.mounted) return;
    var itemRenderBox = context.findRenderObject() as RenderBox;
    var location = itemRenderBox.localToGlobal(Offset.zero);
    groupItem.updateWith(
      setState: setstate,
      position: Offset(location.dx - boardState.boardOffset.dx,
          location.dy - boardState.boardOffset.dy),
      size: groupItem.size == Size.zero ? itemRenderBox.size : null,
    );

    /// This is used to
    if (boardState.groups[groupIndex].items[itemIndex].key.currentContext ==
            null ||
        !boardState
            .groups[groupIndex].items[itemIndex].key.currentContext!.mounted) {
      setstate();
    }
  }

  void resetItemWidget() {
    final groupItem = boardState
        .groups[boardState.draggingState.currentGroupIndex]
        .items[boardState.draggingState.currentIndex];
    groupItem.placeHolderAt = PlaceHolderAt.none;
  }

  bool calculateSizePosition({
    required int groupIndex,
    required int itemIndex,
  }) {
    final group = boardState.groups[groupIndex];
    var groupItem = group.items[itemIndex];

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

  void addPlaceHolder({required int groupIndex, required int itemIndex}) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;
    groupItem.ghost = Column(
      children: [
        groupItem.placeHolderAt == PlaceHolderAt.top
            ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 3000),
                curve: Curves.ease,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.grey.shade200),
                  //   borderRadius: BorderRadius.circular(4),
                  //   color: groupItem.backgroundColor ?? Colors.white,
                  // ),
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  width: draggingState.feedbackSize.width,
                  height: draggingState.feedbackSize.height,
                  child: DottedBorder(
                    child: Center(
                        child: Text(
                      "Drop your task here TOP-$itemIndex",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              )
            : Container(),
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          tween: Tween<double>(
              begin: groupItem.placeHolderAt == PlaceHolderAt.bottom
                  ? groupItem.actualSize.height
                  : -groupItem.actualSize.height,
              end: 0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, value),
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            width: groupItem.size.width,
            child: groupItem.itemWidget,
          ),
        ),
        groupItem.placeHolderAt == PlaceHolderAt.bottom
            ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 3000),
                curve: Curves.ease,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.grey.shade200),
                  //   borderRadius: BorderRadius.circular(4),
                  //   color: groupItem.backgroundColor ?? Colors.white,
                  // ),
                  margin: const EdgeInsets.only(top: 10),
                  width: draggingState.feedbackSize.width,
                  height: draggingState.feedbackSize.height,
                  child: DottedBorder(
                    child: Center(
                        child: Text(
                      "Drop your task here BOTTOM-$itemIndex",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  bool isPrevSystemCard({required int groupIndex, required int itemIndex}) {
    final draggingState = boardState.draggingState;
    final groups = boardState.groups;
    var groupItem = groups[groupIndex].items[itemIndex];
    if (groups[draggingState.currentGroupIndex]
        .items[draggingState.currentIndex]
        .addedBySystem) {
      groups[draggingState.currentGroupIndex].items = [];
      log("ITEM REMOVED");
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        groups[draggingState.currentGroupIndex].setState();
        draggingState.currentIndex = itemIndex;
        draggingState.currentGroupIndex = groupIndex;
        //  log("UPDATED | ITEM= ${draggingState.currentIndex} | LIST= $groupIndex");
        groupItem.setState();
      });

      return true;
    }
    return false;
  }

  void checkForYAxisMovement(
      {required int groupIndex, required int itemIndex}) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;
    bool willPlaceHolderAtBottom =
        _bottomPlaceHolderPossibility(groupIndex, itemIndex);
    if (getYAxisCondition(groupIndex: groupIndex, itemIndex: itemIndex)) {
      resetItemWidget();

      groupItem.placeHolderAt =
          willPlaceHolderAtBottom ? PlaceHolderAt.bottom : PlaceHolderAt.top;

      print("ENTER Y-AXIS $groupIndex $itemIndex");
      if ((!groupItem.addedBySystem)) {
        addPlaceHolder(groupIndex: groupIndex, itemIndex: itemIndex);
        // log("${groupItem.placeHolderAt.name}=>${groupItem.size.height}");
      }
      if (isPrevSystemCard(groupIndex: groupIndex, itemIndex: itemIndex))
        return;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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

        if (itemIndex != draggingState.currentIndex &&
            draggingState.currentGroupIndex != groupIndex) {
          groups[draggingState.currentGroupIndex]
              .items[draggingState.currentIndex]
              .placeHolderAt = PlaceHolderAt.none;
        }
        print("EXIT Y-AXIS $groupIndex $itemIndex");
        groups[draggingState.currentGroupIndex]
            .items[draggingState.currentIndex]
            .setState();
        draggingState.currentIndex = itemIndex;
        draggingState.currentGroupIndex = groupIndex;
        groupItem.setState();
      });
    }
  }

  bool isLastItemDragged({required int groupIndex, required int itemIndex}) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;
    if (draggingState.dragStartIndex == itemIndex &&
        draggingState.dragStartGroupIndex == groupIndex &&
        groups[groupIndex].items.length - 1 == itemIndex &&
        draggingState.currentIndex == itemIndex &&
        draggingState.currentGroupIndex == groupIndex) {
      return true;
    }
    groupItem.position!.dy;
    if ((draggingState.dragStartIndex == itemIndex &&
        draggingState.dragStartGroupIndex == groupIndex &&
        draggingState.currentGroupIndex == groupIndex &&
        groups[groupIndex].items.length - 1 == itemIndex &&
        ((draggingState.feedbackSize.height * 0.6) +
                draggingState.feedbackOffset.value.dy >
            groupItem.position!.dy + groupItem.size.height))) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        // log("PREVIOUS |${draggingState.currentGroupIndex}| LIST= ${draggingState.currentIndex}");

        /// TODO: previous child logic
        // groups[draggingState.currentGroupIndex]
        //         .items[draggingState.currentIndex]
        //         .child =
        //     groups[draggingState.currentGroupIndex]
        //         .items[draggingState.currentIndex]
        //         .prevChild;
        groups[draggingState.currentGroupIndex]
            .items[draggingState.currentIndex]
            .setState();
        draggingState.currentIndex = itemIndex;
        draggingState.currentGroupIndex = groupIndex;

        // log("UP/DOWN $groupIndex $itemIndex");
        groupItem.setState();
      });
      return true;
    }
    return false;
  }

  bool _topPlaceHolderPossibility(int groupIndex, int itemIndex) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;

    // if (groupItem.index == 1 && groupItem.groupIndex == 0) {
    //   log("${draggingState.feedbackOffset.value.dy} < ${groupItem.position!.dy} + ${(groupItem.size.height)}");
    // }
    // log("TOP PLACEHOLDER");
    // log("TOP PLACEHOLDER | ${groupItem.placeHolderAt.name} | ${groupItem.position!.dy} | ${groupItem.actualSize.height} | ${draggingState.feedbackOffset.value.dy} | ${groupItem.position!.dy + (groupItem.actualSize.height * 0.65)}"

    var willPlaceHolderAtTop = groupItem.placeHolderAt == PlaceHolderAt.bottom
        ? (draggingState.feedbackOffset.value.dy <
            groupItem.position!.dy + (groupItem.actualSize.height * 0.5))
        : ((draggingState.feedbackOffset.value.dy <=
                groupItem.position!.dy + (groupItem.actualSize.height * 0.5)) &&
            (draggingState.feedbackSize.height +
                    draggingState.feedbackOffset.value.dy >
                groupItem.position!.dy + (groupItem.actualSize.height)));

    // if (groupItem.placeHolderAt == PlaceHolderAt.bottom) {
    //   print("BOTTOM TRUE");
    // }

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

  void checkForXAxisMovement(
      {required int groupIndex, required int itemIndex}) {
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

      print("ENTER X-AXIS $groupIndex $itemIndex");
      addPlaceHolder(groupIndex: groupIndex, itemIndex: itemIndex);
      if (isPrevSystemCard(groupIndex: groupIndex, itemIndex: itemIndex))
        return;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (itemIndex != draggingState.currentIndex &&
            draggingState.currentGroupIndex != groupIndex) {
          groups[draggingState.currentGroupIndex]
              .items[draggingState.currentIndex]
              .placeHolderAt = PlaceHolderAt.none;
        }
        groups[draggingState.currentGroupIndex]
            .items[draggingState.currentIndex]
            .setState();

        draggingState.currentIndex = itemIndex;
        draggingState.currentGroupIndex = groupIndex;
        print("EXIT X-AXIS $groupIndex $itemIndex");
        groupItem.setState();
      });
    }
  }

  /// This method is called on the [LongPress] event of the group-groupItem widget.
  /// It is responsible for setting the state of the dragged groupItem with updated position and size.
  void onLongPressItem(
      {required int groupIndex,
      required int itemIndex,
      required BuildContext context,
      required VoidCallback setsate}) {
    final groups = boardState.groups;
    final groupItem = groups[groupIndex].items[itemIndex];
    final draggingState = boardState.draggingState;
    var box = context.findRenderObject() as RenderBox;
    var location = box.localToGlobal(Offset.zero);
    groupItem.updateWith(
      position: Offset(location.dx - boardState.boardOffset.dx,
          location.dy - boardState.boardOffset.dy),
      size: box.size,
      actualSize: box.size,
      setState: setsate,
    );
    draggingState.feedbackOffset.value = groupItem.position!;
    print("LONG PRESS ${groupIndex}");
    draggingState.updateWith(
        feedbackSize: groupItem.size,
        draggableType: DraggableType.item,
        dragStartIndex: itemIndex,
        dragStartGroupIndex: groupIndex,
        currentIndex: itemIndex,
        currentGroupIndex: groupIndex,
        draggingWidget: Opacity(
            opacity: 0.5,
            child: Container(
              height: groupItem.size.height,
              width: groupItem.size.width,
              child: groupItem.itemWidget,
            )));
    setsate();
  }

  bool isCurrentElementDragged(
      {required int groupIndex, required int itemIndex}) {
    final draggingState = boardState.draggingState;

    return draggingState.draggableType == DraggableType.item &&
        draggingState.dragStartIndex == itemIndex &&
        draggingState.dragStartGroupIndex == groupIndex;
  }

  // void saveNewCard() {
  //   var boardProv = ref.read(ProviderList.boardProvider);
  //   final cardState = boardProv.newCardState;
  //   boardgroups[cardState.groupIndex!].items[cardState.cardIndex!].child =
  //       Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade200),
  //       borderRadius: BorderRadius.circular(4),
  //       color: Colors.white,
  //     ),
  //     margin: const EdgeInsets.only(bottom: 10),
  //     padding: const EdgeInsets.all(12),
  //     child: Text(boardProv.newCardState.textController.text,
  //         style: boardProv.board.textStyle),
  //   );
  //   boardgroups[cardState.groupIndex!].items[cardState.cardIndex!].prevChild =
  //       boardgroups[cardState.groupIndex!].items[cardState.cardIndex!].child;
  //   cardState.isFocused = false;
  //   boardgroups[cardState.groupIndex!].items[cardState.groupIndex!].isNew =
  //       false;
  //   boardProv.newCardState.textController.clear();
  //   boardgroups[cardState.groupIndex!].items[cardState.groupIndex!].setState!();
  //   cardState.cardIndex = null;
  //   cardState.groupIndex = null;
  //   log("TAPPED");
  // }

  /// This method is called on the onDragEnd event of the draggable widget
  /// It is responsible for reordering the card in the board
  void onDragEnd() {
    final groups = boardState.groups;
    final draggedState = boardState.draggingState;

    IKanbanBoardGroup group = boardState.groups[draggedState.currentGroupIndex];
    IKanbanBoardGroupItem groupItem = group.items[draggedState.currentIndex];

    /// If the card is dropped in the same group.
    if (draggedState.dragStartGroupIndex == draggedState.currentGroupIndex) {
      /// Remove the groupItem from the index from where it was dragged, and insert it at the current index.
      group.items.insert(
          draggedState.currentIndex,
          groups[draggedState.dragStartGroupIndex]
              .items
              .removeAt(draggedState.dragStartIndex));
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
        group.items.insert(
            draggedState.currentIndex + 1,
            groups[draggedState.dragStartGroupIndex]
                .items
                .removeAt(draggedState.dragStartIndex));
      } else {
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
    groupItem.placeHolderAt = PlaceHolderAt.none;

    /// Rebuild the current group to which the groupItem is dropped.
    groups[draggedState.currentGroupIndex].setState();
    // Rebuild the group from which the groupItem was dragged.
    groups[draggedState.dragStartGroupIndex].setState();

    /// Reset the dragging state to its initial state.
    boardState.draggingState = DraggableState.initial();
  }
}

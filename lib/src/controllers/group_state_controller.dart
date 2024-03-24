import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:kanban_board/src/controllers/board_state_controller.dart';
import 'package:kanban_board/src/constants/constants.dart';
import 'states/board_internal_states.dart';
import 'states/draggable_state.dart';

class GroupStateController extends ChangeNotifier {
  GroupStateController(this.boardState);
  final BoardStateController boardState;
  bool isScrolling = false;

  void calculateSizePosition(
      {required BoardStateController boardState,
      required int groupIndex,
      required BuildContext context,
      required VoidCallback setstate}) {
    final group = boardState.groups[groupIndex];
    var groupRenderbox = context.findRenderObject() as RenderBox;
    var position = groupRenderbox.localToGlobal(Offset.zero);
    group
      ..position = Offset(position.dx - boardState.boardOffset.dx - 10,
          position.dy - boardState.boardOffset.dy + 24)
      ..setState = setstate
      ..size = groupRenderbox.size;
  }

  // Future addNewCard({required String position, required int groupIndex}) async {
  //   var prov = ref.read(ProviderList.boardProvider);
  //   final cardState = prov.newCardState;
  //   if (cardState.isFocused == true) {
  //     ref.read(ProviderList.cardProvider).saveNewCard();
  //   }

  //   var scroll = prov.board.groups[groupIndex].scrollController;

  //   // log("MAX EXTENT =${scroll.position.maxScrollExtent}");

  //   prov.board.groups[groupIndex].items.insert(
  //       position == "TOP" ? 0 : prov.board.groups[groupIndex].items.length,
  //       ListItem(
  //         child: Container(
  //             width: prov.board.groups[groupIndex].width,
  //             color: Colors.white,
  //             margin: const EdgeInsets.only(bottom: 10),
  //             child: const TField()),
  //         groupIndex: groupIndex,
  //         isNew: true,
  //         index: prov.board.groups[groupIndex].items.length,
  //         prevChild: Container(
  //             width: prov.board.groups[groupIndex].width,
  //             color: Colors.white,
  //             margin: const EdgeInsets.only(bottom: 10),
  //             padding: const EdgeInsets.all(10),
  //             child: const TField()),
  //       ));
  //   position == "TOP" ? await scrollToMin(scroll) : scrollToMax(scroll);
  //   cardState.groupIndex = groupIndex;
  //   cardState.isFocused = true;
  //   cardState.cardIndex =
  //       position == "TOP" ? 0 : prov.board.groups[groupIndex].items.length - 1;
  //   prov.board.groups[groupIndex].setState!();
  // }

  void onListLongpress(
      {required BoardStateController boardState,
      required int groupIndex,
      required BuildContext context,
      required VoidCallback setstate}) {
    for (final group in boardState.groups) {
      if (group.key.currentState == null || !group.key.currentState!.mounted) {
        break;
      }
      final itemRenderBox =
          group.key.currentState!.context.findRenderObject() as RenderBox;
      final position = itemRenderBox.localToGlobal(Offset.zero);
      group
        ..position = Offset(
            position.dx - boardState.boardOffset.dx - LIST_GAP, position.dy)
        ..setState = setstate
        ..size = itemRenderBox.size;
    }
    boardState.draggingState.feedbackOffset.value =
        boardState.groups[groupIndex].position! + const Offset(LIST_GAP, 0);

    boardState.draggingState.updateWith(
        draggingWidget: Container(
          height: 100,
          width: 100,
          color: Colors.red,
        ),
        draggableType: DraggableType.group,
        feedbackSize: boardState.groups[groupIndex].size,
        dragStartGroupIndex: groupIndex,
        currentIndex: -1,
        currentGroupIndex: -1,
        dragStartIndex: -1);
    setstate();
  }

  void moveListRight(BoardStateController boardState) {
    final draggingState = boardState.draggingState;
    final groups = boardState.groups;
    if (draggingState.dragStartGroupIndex == groups.length - 1) {
      return;
    }
    if (draggingState.feedbackOffset.value.dx +
            groups[draggingState.dragStartGroupIndex].size.width / 2 <
        groups[draggingState.dragStartGroupIndex + 1].position!.dx) {
      return;
    }
    // dev.log("LIST RIGHT");
    groups.insert(draggingState.dragStartGroupIndex + 1,
        groups.removeAt(draggingState.dragStartGroupIndex));
    draggingState.dragStartGroupIndex++;
    draggingState.currentIndex = -1;
    draggingState.currentGroupIndex = -1;
    draggingState.dragStartIndex = -1;
    groups[draggingState.dragStartGroupIndex - 1].setState();
    groups[draggingState.dragStartGroupIndex].setState();
  }

  void moveListLeft(BoardStateController boardState) {
    final draggingState = boardState.draggingState;
    final groups = boardState.groups;
    if (draggingState.dragStartGroupIndex == 0) {
      return;
    }

    if (draggingState.feedbackOffset.value.dx >
        groups[draggingState.dragStartGroupIndex].position!.dx +
            (groups[draggingState.dragStartGroupIndex - 1].size.width / 2)) {
      // dev.log(
      // "RETURN LEFT LIST ${prov.valueNotifier.value.dx} ${prov.board.lists[prov.draggedItemState!.groupIndex! - 1].x! + (prov.board.lists[prov.draggedItemState!.groupIndex! - 1].width! / 2)} ");
      return;
    }
    // dev.log("LIST LEFT ${prov.valueNotifier.value.dx} ${prov.board.lists[prov.draggedItemState!.groupIndex! - 1].x! + (prov.board.lists[prov.draggedItemState!.groupIndex! - 1].width! / 2)} ");
    groups.insert(draggingState.dragStartGroupIndex - 1,
        groups.removeAt(draggingState.dragStartGroupIndex));
    draggingState.dragStartGroupIndex--;
    draggingState.currentIndex = -1;
    draggingState.currentGroupIndex = -1;
    draggingState.dragStartIndex = -1;
    groups[draggingState.dragStartGroupIndex].setState();
    groups[draggingState.dragStartGroupIndex + 1].setState();
  }

  void createNewList() {}

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
      group.items.add(IKanbanBoardGroupItem(
          key: GlobalKey(),
          id: 'system-added-placeholder',
          index: 0,
          setState: () => {},
          placeHolderAt: PlaceHolderAt.none,
          itemWidget: Container(
            margin: const EdgeInsets.only(
              bottom: 10,
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
          groupIndex: groupIndex));
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// Remove the placeholder from the previous group-item.
      boardState.groups[draggingState.currentGroupIndex]
          .items[draggingState.currentIndex].placeHolderAt = PlaceHolderAt.none;

      /// If the last placeholder was added by the system as item in the group, then remove it.
      if (boardState.groups[draggingState.currentGroupIndex]
              .items[draggingState.currentIndex].addedBySystem ==
          true) {
        boardState.groups[draggingState.currentGroupIndex].items.removeAt(0);
        boardState.groups[draggingState.currentGroupIndex].setState();
      }

      /// Update the dragging state.
      draggingState.currentIndex = 0;
      draggingState.currentGroupIndex = groupIndex;

      /// Rebuild the group.
      group.setState();
    });
  }

  /// [canItemDropOverGroup] checks if the dragged item can be dropped on the group or not.
  /// It checks if the item is entering the group from the left or right side.
  bool canItemDropOverGroup(int groupIndex) {
    final draggingState = boardState.draggingState;
    final group = boardState.groups[groupIndex];
    final draggableOffset = draggingState.feedbackOffset.value;

    /// Check if the item is entering the group from the left side.
    final bool entringFromLeft =
        (draggableOffset.dx < group.position!.dx + (group.size.width * 0.4)) &&
            ((group.position!.dx + group.size.width <
                draggingState.feedbackSize.width + draggableOffset.dx));

    /// Check if the item is entering the group from the right side.
    final entringFromRight =
        (draggingState.feedbackSize.width + draggableOffset.dx >
                group.position!.dx + (group.size.width * 0.6)) &&
            (group.position!.dx + group.size.width >
                draggingState.feedbackSize.width + draggableOffset.dx);

    /// For item to change group, it should not be in the same group.
    return (entringFromLeft || entringFromRight) &&
        draggingState.currentGroupIndex != groupIndex;
  }
}

import 'package:flutter/material.dart';
import 'package:kanban_board/src/controllers/board_state_controller.dart';
import 'package:kanban_board/src/constants/constants.dart';
import 'package:kanban_board/src/controllers/scroll_handler.dart';
import 'states/draggable_state.dart';
import 'states/scroll_state.dart';

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

  /// This function is called when the user is dragging a group-item near the edge of the group-end.
  /// This function can variate the velocity of the scroll based on the distance of the draggable to the edge of the group.
  Future<void> checkGroupScroll(ScrollConfig groupScrollConfig) async {

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
}

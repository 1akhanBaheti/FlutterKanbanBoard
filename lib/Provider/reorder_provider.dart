import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/board_list.dart';
import '../models/dragged_element.dart';

class ReorderProvider extends ChangeNotifier {
  ValueNotifier<Offset> valueNotifier = ValueNotifier<Offset>(Offset.zero);
  double screenHeight = 0.0;
  DraggedItemState? draggedItemState;
  Board board = Board(
      controller: ScrollController(),
      lists: List.generate(
          10,
          (listIndex) => BoardList(
              scrollController: ScrollController(),
              title: "List $listIndex",
              items: List.generate(
                  50,
                  (index) => ListItem(
                      index: index,
                      child: Text(
                        "ITEM $index",
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      listIndex: listIndex,
                      height: 0,
                      width: 0,
                      x: 0,
                      y: 0)))));
  void setcanDrag(
      {required bool value, required int itemIndex, required int listIndex}) {
    board.isElementDragged = value;
    board.isListDragged = value;
    var item = board.lists[listIndex].items[itemIndex];
    draggedItemState = DraggedItemState(
        child: item.child,
        listIndex: listIndex,
        itemIndex: itemIndex,
        height: item.height,
        width: item.width,
        x: item.x,
        y: item.y);
    notifyListeners();
  }

  void moveDown(ListItem? element) {
    double position = 0.0;
    if (board.dragItemIndex! + 1 >=
        board.lists[board.dragItemOfListIndex!].items.length) {
      return;
    }

    if (valueNotifier.value.dx >
        board.lists[board.dragItemOfListIndex!].x! +
            (board.lists[board.dragItemOfListIndex!].width! / 2)) {
      return;
    }
    position = board
        .lists[board.dragItemOfListIndex!].items[board.dragItemIndex! + 1].y;

    if (valueNotifier.value.dy + 50 > position &&
        valueNotifier.value.dy + 50 < position + 130) {
      board.lists[board.dragItemOfListIndex!].items
          .removeAt(board.dragItemIndex!);
      board.lists[board.dragItemOfListIndex!].items.insert(
          board.dragItemIndex! + 1,
          ListItem(
              child: Container(
                width: 500,
                // key: ValueKey("xlwq${itemIndex! + 1}"),
                color: Colors.green,
                height: 50,
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "ITEM ${draggedItemState!.itemIndex! + 1}",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              listIndex: board.dragItemOfListIndex!,
              index: board.dragItemIndex! + 1,
              height: board.lists[board.dragItemOfListIndex!]
                  .items[board.dragItemIndex!].height,
              width: board.lists[board.dragItemOfListIndex!]
                  .items[board.dragItemIndex!].width,
              x: 0,
              y: 0));
      board.dragItemIndex = board.dragItemIndex! + 1;
    }
  }

  void updateValue({
    required double dx,
    required double dy,
  }) {
    valueNotifier.value = Offset(dx, dy);
   // notifyListeners();
  }

  void setsState() {
    notifyListeners();
  }
}

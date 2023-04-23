import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/board_list.dart';
import '../models/dragged_element.dart';

class ReorderProvider extends ChangeNotifier {
  ValueNotifier<Offset> valueNotifier = ValueNotifier<Offset>(Offset.zero);
  ListItem? draggedItemState;
  Board board = Board(
      controller: ScrollController(),
      lists: List.generate(
          4,
          (listIndex) => BoardList(
              scrollController: ScrollController(),
              title: "List $listIndex",
              items: List.generate(
                  25,
                  (index) => ListItem(
                      index: index,
                      child: Container(
                        key: ValueKey("!+$index"),
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        height: 50,
                        width: 80,
                        alignment: Alignment.center,
                        color: Colors.pink,
                        child: Text(
                          "ITEM $index",
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      listIndex: listIndex,
                      height: 0,
                      width: 0,
                      x: 0,
                      y: 0)))));
  void setcanDrag(
      {required bool value, required int itemIndex, required int listIndex}) {
    board.isElementDragged = value;
    var item = board.lists[listIndex].items[itemIndex];
    draggedItemState = ListItem(
        child: item.child,
        listIndex: listIndex,
        index: itemIndex,
        height: item.height,
        width: item.width,
        x: item.x,
        y: item.y);
    notifyListeners();
  }

  void updateValue({
    required double dx,
    required double dy,
  }) {
    valueNotifier.value = Offset(dx, dy);
    notifyListeners();
  }

  void setsState() {
    notifyListeners();
  }
}

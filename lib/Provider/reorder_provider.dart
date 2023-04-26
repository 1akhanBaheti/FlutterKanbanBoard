import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/board_list.dart';
import '../models/inputs.dart';
import '../models/item_state.dart';

class ReorderProvider extends ChangeNotifier {
  ValueNotifier<Offset> valueNotifier = ValueNotifier<Offset>(Offset.zero);
  double screenHeight = 0.0;
  DraggedItemState? draggedItemState;
  TextEditingController newCardTextController = TextEditingController();
  late BoardState board;
  void setcanDrag(
      {required bool value, required int itemIndex, required int listIndex}) {
    board.isElementDragged = value;
    board.isListDragged = value;
    var item = board.lists[listIndex].items[itemIndex];
    draggedItemState = DraggedItemState(
        child: item.child,
        listIndex: listIndex,
        itemIndex: itemIndex,
        height: item.height!,
        width: item.width!,
        x: item.x!,
        y: item.y!);
    notifyListeners();
  }

  void initializeBoard(
      {required List<BoardListsData> data,
      Color backgroundColor = Colors.white,
      TextStyle? textStyle,
      Function(int? itemIndex, int? listIndex)? onItemTap,
      Function(int? cardIndex, int? listIndex)? onItemLongPress,
      Function(int? listIndex)? onListTap,
      Function(int? listIndex)? onListLongPress,
      double? displacementX,
      double? displacementY,
      void Function(int? oldCardIndex, int? newCardIndex, int? oldListIndex,
              int? newListIndex)?
          onItemReorder,
      void Function(int? oldListIndex, int? newListIndex)? onListReorder,
      void Function(String? oldName, String? newName)? onListRename,
      void Function(String? cardIndex, String? listIndex, String? text)?
          onNewCardInsert,
      Decoration? boardDecoration,
      Decoration? listDecoration,
      Widget Function(Widget child, Animation<double> animation)?
          listTransitionBuilder,
      Widget Function(Widget child, Animation<double> animation)?
          cardTransitionBuilder,
      required Duration cardTransitionDuration,
      required Duration listTransitionDuration,
      Color? cardPlaceHolderColor,
      Color? listPlaceHolderColor}) {
    board = BoardState(
        textStyle: textStyle,
        lists: [],
        displacementX: displacementX,
        displacementY: displacementY,
        onItemTap: onItemTap,
        onItemLongPress: onItemLongPress,
        onListTap: onListTap,
        onListLongPress: onListLongPress,
        onItemReorder: onItemReorder,
        onListReorder: onListReorder,
        onListRename: onListRename,
        onNewCardInsert: onNewCardInsert,
        listTransitionBuilder: listTransitionBuilder,
        cardTransitionBuilder: cardTransitionBuilder,
        cardTransitionDuration: cardTransitionDuration,
        listTransitionDuration: listTransitionDuration,
        controller: ScrollController(),
        backgroundColor: backgroundColor,
        cardPlaceholderColor: cardPlaceHolderColor,
        listPlaceholderColor: listPlaceHolderColor,
        listDecoration: listDecoration,
        boardDecoration: boardDecoration);
    for (int i = 0; i < data.length; i++) {
      List<ListItem> listItems = [];
      for (int j = 0; j < data[i].items.length; j++) {
        listItems
            .add(ListItem(child: data[i].items[j], listIndex: i, index: j));
      }
      board.lists.add(BoardList(
          headerBackgroundColor: data[i].headerBackgroundColor,
          footerBackgroundColor: data[i].footerBackgroundColor,
          backgroundColor: data[i].backgroundColor,
          items: listItems,
          width: data[i].width,
          scrollController: ScrollController(),
          title: data[i].title ?? 'LIST ${i + 1}'));
    }
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
        .lists[board.dragItemOfListIndex!].items[board.dragItemIndex! + 1].y!;

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

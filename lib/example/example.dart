import 'package:flutter/material.dart';

import '../board_item.dart';
import '../board_list.dart';
import '../boardview.dart';
import '../boardview_controller.dart';
import 'BoardItemObject.dart';
import 'BoardListObject.dart';

class BoardViewExample extends StatelessWidget {

  final List<BoardListObject> _listData = [
     BoardListObject(title: "STATE 1",items: [
      BoardItemObject(
        
        title: "ITEM1"
      ),
      ...List.generate(25, (index) => BoardItemObject(title: "ITEM1")),
      BoardItemObject(
        title: "ITEM2"
      ),
      BoardItemObject(
        title: "ITEM3"
      ),
      BoardItemObject(
        title: "ITEM4"
      ),
           BoardItemObject(
        title: "ITEM4"
      )
      ,    
     ]),
    BoardListObject(title: "STATE 2"),
    BoardListObject(title: "STATE 3"),
    BoardListObject(title: "STATE 2"),
    BoardListObject(title: "STATE 2"),
    BoardListObject(title: "STATE 2"),
  ];


  //Can be used to animate to different sections of the BoardView
  BoardViewController boardViewController =  BoardViewController();

  BoardViewExample({super.key});



  @override
  Widget build(BuildContext context) {
    List<BoardList> lists = [];
    for (int i = 0; i < _listData.length; i++) {
      lists.add(_createBoardList(_listData[i]) as BoardList);
    }
    return BoardView(
      lists: lists,
      boardViewController: boardViewController,
    );
  }

  Widget buildBoardItem(BoardItemObject itemObject) {
    return BoardItem(
        onStartDragItem: (int? listIndex, int? itemIndex, BoardItemState? state) {

        },
        onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex,
            int? oldItemIndex, BoardItemState? state) {
          //Used to update our local item data
          var item = _listData[oldListIndex!].items![oldItemIndex!];
          _listData[oldListIndex].items!.removeAt(oldItemIndex);
          _listData[listIndex!].items!.insert(itemIndex!, item);
        },
        onTapItem: (int? listIndex, int? itemIndex, BoardItemState? state) async {

        },
        item: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(itemObject.title!),
          ),
        ));
  }

  Widget _createBoardList(BoardListObject list) {
    List<BoardItem> items = [];
    for (int i = 0; i < list.items!.length; i++) {
      items.insert(i, buildBoardItem(list.items![i]) as BoardItem);
    }

    return BoardList(
      onStartDragList: (int? listIndex) {

      },
      onTapList: (int? listIndex) async {

      },
      onDropList: (int? listIndex, int? oldListIndex) {
        //Update our local list data
        var list = _listData[oldListIndex!];
        _listData.removeAt(oldListIndex);
        _listData.insert(listIndex!, list);
      },
      headerBackgroundColor: const Color.fromARGB(255, 235, 236, 240),
      backgroundColor: const Color.fromARGB(255, 235, 236, 240),
      header: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  list.title!,
                  style: const TextStyle(fontSize: 20),
                ))),
      ],
      items: items,
    );
  }
}

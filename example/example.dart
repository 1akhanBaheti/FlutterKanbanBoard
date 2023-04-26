import 'package:flutter/material.dart';
import 'package:kanban_board/custom/board.dart';
import 'package:kanban_board/models/inputs.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return KanbanBoard(
      List.generate(
        8,
        (index) => BoardListsData(
            items: List.generate(
          50,
          (index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "Lorem ipsum dolor sit amet, Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. $index",
                style: TextStyle(
                    fontSize: 19,
                    height: 1.3,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500)),
          ),
        )),
      ),
      onItemLongPress: (cardIndex, listIndex) {},
      onItemReorder:
          (oldCardIndex, newCardIndex, oldListIndex, newListIndex) {},
      onListLongPress: (listIndex) {},
      onListReorder: (oldListIndex, newListIndex) {},
      onItemTap: (cardIndex, listIndex) {},
      onListTap: (listIndex) {},
      onListRename: (oldName, newName) {},
      backgroundColor: Colors.white,
      displacementY: 124,
      displacementX: 100,
      textStyle: TextStyle(
          fontSize: 19,
          height: 1.3,
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500),
    );
  }
}

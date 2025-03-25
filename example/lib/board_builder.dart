import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kanban_board/custom/board.dart';
import 'package:kanban_board/models/inputs.dart';

import 'kanban_data.dart';
import 'widgets/board_header.dart';
import 'widgets/card.dart';
import 'widgets/list_footer.dart';
import 'widgets/list_header.dart';

class BoardBuilder extends StatefulWidget {
  const BoardBuilder({super.key});

  @override
  State<BoardBuilder> createState() => _BoardBuilderState();
}

class _BoardBuilderState extends State<BoardBuilder> {
  get width =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS ? 350 : 250;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 244, 240, 1),
      body: SafeArea(
        child: Column(
          children: [
            const BoardHeader(),
            Container(
              height: 1,
              width: MediaQuery.sizeOf(context).width,
              color: Colors.black,
            ),
            Expanded(
              child: KanbanBoard(
                List.generate(kanbanData.length, (index) {
                  final element = kanbanData.values.elementAt(index);
                  return BoardListsData(
                      backgroundColor: const Color.fromRGBO(249, 244, 240, 1),
                      width: width,
                      footer: const ListFooter(),
                      headerBackgroundColor:
                          const Color.fromRGBO(249, 244, 240, 1),
                      header: ListHeader(
                        title: kanbanData.keys.elementAt(index),
                        stateColor: element['color'],
                      ),
                      items: List.generate(element['items'].length, (index) {
                        int totalTasks = int.parse(element['items'][index]
                                ['tasks']
                            .toString()
                            .split('/')
                            .last);
                        int completedTasks = int.parse(element['items'][index]
                                ['tasks']
                            .toString()
                            .split('/')
                            .first);

                        return KanbanCard(
                          title: element['items'][index]['title'],
                          completedTasks: completedTasks,
                          totalTasks: totalTasks,
                          date: element['items'][index]['date'],
                          tasks: element['items'][index]['tasks'],
                          avatar: persons[index % 4],
                        );
                      }));
                }),
                onItemLongPress: (cardIndex, listIndex) {},
                onItemReorder:
                    (oldCardIndex, newCardIndex, oldListIndex, newListIndex) {},
                onListLongPress: (listIndex) {},
                onListReorder: (oldListIndex, newListIndex) {},
                onItemTap: (cardIndex, listIndex) {},
                onListTap: (listIndex) {},
                onListRename: (oldName, newName) {},
                backgroundColor: const Color.fromRGBO(249, 244, 240, 1),
                displacementY: 124,
                displacementX: 100,
                textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

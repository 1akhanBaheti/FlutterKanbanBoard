import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:kanban_board/kanban_board.dart';

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
  double get width =>
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
                  groupHeaderBuilder: (context, groupId) => ListHeader(
                        stateColor: kanbanData[groupId]!['color'],
                        title: groupId,
                      ),
                  groupFooterBuilder: (context, groupId) => const ListFooter(),
                  boardDecoration: const BoxDecoration(
                    color: Color.fromRGBO(249, 244, 240, 1),
                  ),
                  groupDecoration: const BoxDecoration(
                    color: Color.fromRGBO(249, 244, 240, 1),
                  ),
                  groupConstraints: BoxConstraints(
                      minWidth: width, maxWidth: width, minHeight: 300),
                  controller: KanbanBoardController(),
                  itemGhost: DottedBorder(
                    child: const Center(
                        child: Text(
                      "Drop your task here",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                  ),
                  groups: List.generate(
                      kanbanData.length,
                      (index) => KanbanBoardGroup(
                          id: kanbanData.keys.elementAt(index),
                          name: kanbanData.keys.elementAt(index),
                          items: kanbanData.values
                              .elementAt(index)['items']
                              .map<KanbanCardImpl>((e) => KanbanCardImpl())
                              .toList())),
                  groupItemBuilder: (context, groupId, itemIndex) {
                    var data = kanbanData[groupId];
                    int totalTasks = int.parse(data['items'][itemIndex]['tasks']
                        .toString()
                        .split('/')
                        .last);
                    int completedTasks = int.parse(data['items'][itemIndex]
                            ['tasks']
                        .toString()
                        .split('/')
                        .first);
                    return KanbanCard(
                      title: data['items'][itemIndex]['title'],
                      completedTasks: completedTasks,
                      totalTasks: totalTasks,
                      date: data['items'][itemIndex]['date'],
                      tasks: data['items'][itemIndex]['tasks'],
                      avatar: persons[itemIndex % 4],
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class KanbanCardImpl implements KanbanBoardGroupItem {
  @override

  String get id => 'id';
}

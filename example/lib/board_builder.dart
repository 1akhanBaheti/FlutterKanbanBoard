import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:kanban_board/kanban_board.dart';

import 'kanban_data.dart';
import 'widgets/board_header.dart';
import 'widgets/group_card.dart';
import 'widgets/list_footer.dart';
import 'widgets/list_header.dart';

class BoardBuilder extends StatefulWidget {
  const BoardBuilder({super.key});

  @override
  State<BoardBuilder> createState() => _BoardBuilderState();
}

class _BoardBuilderState extends State<BoardBuilder> {
  double get width =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS ? 350 : 350;
  final _controller = KanbanBoardController();

  @override
  Widget build(BuildContext context) {
    final kanbanGroups = List.generate(
      kanbanData.length,
      (index) => KanbanBoardGroup(
        id: kanbanData.keys.elementAt(index),
        name: kanbanData.keys.elementAt(index),
        items: (kanbanData.values.elementAt(index)['items'] as List)
            .map<KanbanCardImpl>(
              (e) => KanbanCardImpl(
                itemId: index.toString(),
                title: e['title'],
                date: e['date'],
                avatar: persons[
                    kanbanData.values.elementAt(index)['items'].indexOf(e) % 4],
                completedTasks:
                    int.parse(e['tasks'].toString().split('/').first),
                totalTasks: int.parse(e['tasks'].toString().split('/').last),
              ),
            )
            .toList(),
      ),
    );
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
                  controller: _controller,
                  groupHeaderBuilder: (context, groupId) => ListHeader(
                        updateBoard: _updateBoard,
                        controller: _controller,
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
                  itemGhost: DottedBorder(
                    child: const Center(
                        child: Text(
                      "Drop your task here",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                  ),
                  groups: kanbanGroups,
                  groupItemBuilder: (context, groupId, itemIndex) {
                    final groupItem = kanbanGroups
                        .firstWhere((element) => element.id == groupId)
                        .items
                        .elementAt(itemIndex);
                    return GroupCard(
                      title: groupItem.title,
                      completedTasks: groupItem.completedTasks,
                      totalTasks: groupItem.totalTasks,
                      date: groupItem.date,
                      tasks: groupItem.totalTasks.toString(),
                      avatar: persons[itemIndex % 4],
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  void _updateBoard() {
    setState(() {});
  }
}

class KanbanCardImpl extends KanbanBoardGroupItem {
  final String itemId;
  final String title;
  final String date;
  final String avatar;
  final int completedTasks;
  final int totalTasks;

  KanbanCardImpl({
    required this.itemId,
    required this.title,
    required this.date,
    required this.avatar,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  String get id => itemId;
}

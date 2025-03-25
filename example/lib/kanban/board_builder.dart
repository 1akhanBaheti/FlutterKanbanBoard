import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:kanban/constants/kanban_data.dart';
import 'package:kanban_board/kanban_board.dart';
import 'widgets/board_header.dart';
import 'widgets/group_card.dart';
import 'widgets/list_footer.dart';
import 'widgets/list_header.dart';

class KanbanCanvas extends StatefulWidget {
  const KanbanCanvas({super.key});

  @override
  State<KanbanCanvas> createState() => _KanbanCanvasState();
}

class _KanbanCanvasState extends State<KanbanCanvas> {
  final _controller = KanbanBoardController();

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
                controller: _controller,
                groups: kanbanGroups,
                groupHeaderBuilder: groupHeaderBuilder,
                groupFooterBuilder: (context, groupId) => const ListFooter(),
                boardDecoration: const BoxDecoration(
                  color: Color.fromRGBO(249, 244, 240, 1),
                ),
                groupDecoration: const BoxDecoration(
                  color: Color.fromRGBO(249, 244, 240, 1),
                ),
                groupConstraints: groupConstraints,
                itemGhost: ghost,
                groupGhost: Container(
                  color: Colors.red,
                  height: 100,
                  width: 100,
                ),
                
                groupItemBuilder: groupItemBuilder,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget get ghost => DottedBorder(
        child: const Center(
          child: Text(
            "Drop your task here",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget groupHeaderBuilder(BuildContext context, String groupId) {
    final groupIndex =
        kanbanGroups.indexWhere((element) => element.id == groupId);
    final group = kanbanGroups[groupIndex];
    return ListHeader(
      stateColor: group.customData?.color ?? Colors.transparent,
      title: group.customData?.title ?? '',
    );
  }

  Widget groupItemBuilder(BuildContext context, String groupId, int itemIndex) {
    final groupIndex =
        kanbanGroups.indexWhere((element) => element.id == groupId);
    final groupItem = kanbanGroups[groupIndex].items[itemIndex];
    return GroupCard(
      title: groupItem.title,
      completedTasks: groupItem.completedTasks,
      totalTasks: groupItem.totalTasks,
      date: groupItem.date,
      tasks: groupItem.totalTasks.toString(),
      avatar: groupItem.avatar,
    );
  }

  double get groupWidth =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? 350
          : MediaQuery.sizeOf(context).width * 0.8;

  BoxConstraints get groupConstraints => BoxConstraints(
        minWidth: groupWidth,
        maxWidth: groupWidth,
      );
}

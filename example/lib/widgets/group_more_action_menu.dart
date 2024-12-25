import 'package:flutter/material.dart';
import 'package:kanban/board_builder.dart';
import 'package:kanban/kanban_data.dart';
import 'package:kanban/models/group_more_action.dart';
import 'package:kanban_board/kanban_board.dart';

class GroupMoreActionMenu extends StatelessWidget {
  const GroupMoreActionMenu({
    required this.controller,
    required this.updateBoard,
    super.key,
  });
  final KanbanBoardController controller;
  final VoidCallback updateBoard;

  IconData _getActionIconData(GroupMoreAction action) => switch (action) {
        GroupMoreAction.editTitle => Icons.edit,
        GroupMoreAction.createNewTask => Icons.done,
        GroupMoreAction.deleteGroup => Icons.delete,
      };

  void _onTap(GroupMoreAction action) {
    if (action == GroupMoreAction.editTitle) {
    } else if (action == GroupMoreAction.createNewTask) {
      controller.showNewCard(
        groupId: 'Blocked',
        position: 0,
        onCardAdded: (p0) {
          kanbanData['Blocked']?['items'].insert(
            0,
            {
              'title': 'Task $p0',
              'date': '2021-10-10',
              'tasks': '3/5',
            },
          );
          controller.addGroupItem(
            groupId: 'Blocked',
            groupItem: KanbanCardImpl(
              itemId: p0.toString(),
              title: 'Task $p0',
              completedTasks: 3,
              totalTasks: 5,
              date: '2021-10-10',
              avatar: persons[2],
            ),
          );
          updateBoard();
        },
      );
    } else if (action == GroupMoreAction.deleteGroup) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      constraints: const BoxConstraints(
        minWidth: 200,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(
          color: Colors.black,
        ),
      ),
      itemBuilder: (context) {
        return GroupMoreAction.values
            .map(
              (action) => PopupMenuItem(
                onTap: () => _onTap(action),
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      _getActionIconData(action),
                      size: 16,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 13,
                    ),
                    Text(
                      action.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList();
      },
      child: Container(
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: const Icon(
          Icons.more_horiz,
          size: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}

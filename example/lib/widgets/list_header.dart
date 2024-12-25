import 'package:flutter/material.dart';
import 'package:kanban/widgets/group_more_action_menu.dart';
import 'package:kanban_board/kanban_board.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.controller,
    required this.title,
    required this.stateColor,
    required this.updateBoard,
  });
  final String title;
  final Color stateColor;
  final KanbanBoardController controller;
  final VoidCallback updateBoard;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.only(right: 10),
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: stateColor,
              )),
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          GroupMoreActionMenu(
            controller: controller,
            updateBoard: updateBoard,
          )
        ],
      ),
    );
  }
}

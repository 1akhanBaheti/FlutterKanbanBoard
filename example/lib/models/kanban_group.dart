import 'package:flutter/material.dart';
import 'package:kanban_board/kanban_board.dart';

class KanbanGroup {
  final String id;
  final String title;
  final Color color;

  KanbanGroup({
    required this.id,
    required this.title,
    required this.color,
  });
}

class KanbanGroupItem extends KanbanBoardGroupItem {
  final String itemId;
  final String title;
  final String date;
  final String avatar;
  final int completedTasks;
  final int totalTasks;

  KanbanGroupItem({
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

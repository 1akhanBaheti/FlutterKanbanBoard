import 'package:flutter/material.dart';
import 'index.dart';

class BoardStateController extends ChangeNotifier {
  BoardStateController({
    required this.controller,
    this.groups = const [],
  });

  /// These are the list of internal group-state of the board.
  /// Each group-state holds the state of group and its items.
  List<IKanbanBoardGroup> groups = [];

  /// The controller for the board.
  KanbanBoardController controller;

  /// It holds whether the board is currently scrolling or not.
  bool isScrolling = false;

  /// It holds the state of widget currently being dragged.
  DraggableState draggingState = DraggableState();

  /// It holds the board position
  Offset boardOffset = Offset.zero;

  void notify() {
    notifyListeners();
  }
}

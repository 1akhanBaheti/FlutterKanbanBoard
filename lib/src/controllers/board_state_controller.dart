import 'package:flutter/material.dart';
import 'index.dart';
import 'scroll_handler.dart';

class BoardProvider extends ChangeNotifier {
  BoardProvider(this.boardState);

  final BoardStateController boardState;
  var scrolling = false;
  var scrollingRight = false;
  var scrollingLeft = false;



}

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

  /// Scroll handler for the board and its groups.
  /// It is used to handle the scrolling of the board and its groups, when a widget is being dragged.
  ScrollHandler scrollHandler = ScrollHandler();

  /// It holds the state of widget currently being dragged.
  DraggableState draggingState = DraggableState();

  /// It holds the board position
  Offset boardOffset = Offset.zero;

  void notify() {
    notifyListeners();
  }
}

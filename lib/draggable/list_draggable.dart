import 'package:kanban_board/draggable/draggable_state.dart';

class ListDraggable extends DraggableState {
  ListDraggable(
      {required int index,
      required listIndex,
      required super.height,
      required super.width,
      required super.context,
      required super.widget,
      required super.currPos}) {
    _index = index;
  }
  late int _index;

  int get index => _index;
  void setDataPosition(int index) {
    _index = index;
  }
}

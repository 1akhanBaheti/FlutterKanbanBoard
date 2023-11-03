import 'package:kanban_board/draggable/draggable_state.dart';

class CardDraggable extends DraggableState {
  late int _index;
  late int _listIndex;

  CardDraggable(
      {required int index,
      required listIndex,
      required super.height,
      required super.width,
      required super.context,
      required super.widget,
      required super.currPos}) {
    _index = index;
    _listIndex = listIndex;
  }

  int get index => _index;
  int get listIndex => _listIndex;

  void setDataPosition({required int index, required int listIndex}) {
    _index = index;
    _listIndex = listIndex;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/draggable/card_draggable.dart';
import 'package:kanban_board/draggable/draggable_state.dart';
import 'package:kanban_board/draggable/list_draggable.dart';

class DraggableProviderState {
  CardDraggable? cardDraggable;
  ListDraggable? listDraggable;
  DraggableType draggableType;
  bool get isCardDragged => draggableType == DraggableType.card;
  bool get isListDragged => draggableType == DraggableType.list;

  DraggableProviderState(
      {this.cardDraggable,
      this.draggableType = DraggableType.none,
      this.listDraggable});

  DraggableProviderState copyWith(
      {CardDraggable? cardDraggable,
      ListDraggable? listDraggable,
      DraggableType? draggableType}) {
    return DraggableProviderState(
        cardDraggable: cardDraggable ?? this.cardDraggable,
        listDraggable: listDraggable ?? this.listDraggable,
        draggableType: draggableType ?? this.draggableType);
  }
}

class DraggableNotfier extends StateNotifier<DraggableProviderState> {
  DraggableNotfier(this.ref) : super(DraggableProviderState());
  StateNotifierProviderRef<DraggableNotfier, DraggableProviderState> ref;
  void setDraggableType(DraggableType draggableType) {
    state = state.copyWith(draggableType: draggableType);
  }

  void stopDragging() {
    setDraggableType(DraggableType.none);
  }
}

import 'package:flutter/material.dart';
// Riverpod:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/controllers/states/scroll_state.dart';
import 'package:kanban_board/src/controllers/index.dart'
    show
        BoardStateController,
        DraggableType,
        GroupStateController,
        GroupItemStateController;

/// [KanbanGestureListener] is used to listen to the pointer events and update the position of dragging-widget accordingly.
class KanbanGestureListener extends ConsumerStatefulWidget {
  const KanbanGestureListener(
      {required this.boardStateController,
      required this.boardgroupController,
      required this.groupItemController,
      required this.boardScrollController,
      required this.groupScrollConfig,
      required this.boardScrollConfig,
      this.child,
      super.key});
  final ChangeNotifierProvider<BoardStateController> boardStateController;
  final ChangeNotifierProvider<GroupStateController> boardgroupController;
  final ChangeNotifierProvider<GroupItemStateController> groupItemController;
  final ScrollController boardScrollController;
  final ScrollConfig groupScrollConfig;
  final ScrollConfig boardScrollConfig;
  final Widget? child;
  @override
  ConsumerState<KanbanGestureListener> createState() =>
      _KanbanGestureListenerState();
}

class _KanbanGestureListenerState extends ConsumerState<KanbanGestureListener> {
  /// This method is called when the pointer is up.
  void _onPointerUp(PointerUpEvent event) {
    final boardState = ref.read(widget.boardStateController);
    final draggingState = boardState.draggingState;

    if (draggingState.draggableType == DraggableType.item) {
      ref.read(widget.groupItemController).onDragEnd();
    }
  }

  /// This method is called when the pointer moves.
  void _onPointerMove(PointerMoveEvent event) {
    final boardState = ref.read(widget.boardStateController);
    final draggingState = boardState.draggingState;

    // else if (draggableProv.isListDragged) {
    //   if (event.delta.dx > 0) {
    //     boardProv.boardScroll();
    //     boardListProv.moveListRight();
    //   } else {
    //     boardProv.boardScroll();
    //     boardListProv.moveListLeft();
    //   }
    // }

    final previousOffset = boardState.draggingState.feedbackOffset.value;
    if ((event.position.dx - previousOffset.dx).abs() >= 100 ||
        (event.position.dy - previousOffset.dy).abs() >= 100) {
      boardState.draggingState.axisDirection =
          event.delta.dy > 0 ? AxisDirection.down : AxisDirection.up;
      boardState.draggingState.feedbackOffset.value = Offset(
          event.delta.dx + previousOffset.dx,
          event.delta.dy + previousOffset.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerUp: _onPointerUp,
        onPointerMove: _onPointerMove,
        child: widget.child);
  }
}

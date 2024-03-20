import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/controllers/board_state_controller.dart';
import 'package:kanban_board/src/controllers/states/draggable_state.dart';

/// [DraggableOverlay] is used to show the dragging widget.
/// It makes use of [ValueListenableBuilder] to listen to the [feedbackOffset] and update its position accordingly.
class DraggableOverlay extends ConsumerStatefulWidget {
  const DraggableOverlay({required this.boardState, super.key});
  final ChangeNotifierProvider<BoardStateController> boardState;
  @override
  ConsumerState<DraggableOverlay> createState() => _DraggableOverlayState();
}

class _DraggableOverlayState extends ConsumerState<DraggableOverlay> {
  @override
  Widget build(BuildContext context) {
    final draggingState = ref.watch(widget.boardState).draggingState;
    return ValueListenableBuilder(
      valueListenable: draggingState.feedbackOffset,
      builder: (ctx, Offset value, child) {
        if (draggingState.draggableType == DraggableType.item) {
          //TODO: implement this
          // boardListProv.maybeListScroll();
        }
        return draggingState.draggableType != DraggableType.none
            ? Positioned(
                left: value.dx,
                top: value.dy,
                child: Opacity(
                  opacity: 0.4,
                  child: draggingState.draggingWidget,
                ),
              )
            : Container();
      },
    );
  }
}

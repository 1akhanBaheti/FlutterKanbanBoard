import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/controllers/board_state_controller.dart';
import 'package:kanban_board/src/controllers/group_state_controller.dart';
import 'package:kanban_board/src/controllers/scroll_handler.dart';
import 'package:kanban_board/src/controllers/states/draggable_state.dart';
import 'package:kanban_board/src/controllers/states/scroll_state.dart';

/// [DraggableOverlay] is used to show the dragging widget.
/// It makes use of [ValueListenableBuilder] to listen to the [feedbackOffset] and update its position accordingly.
class DraggableOverlay extends ConsumerStatefulWidget {
  const DraggableOverlay(
      {required this.boardState,
      required this.groupState,
      required this.boardScrollController,
      this.groupScrollConfig,
      this.boardScrollConfig,
      super.key});
  final ChangeNotifierProvider<BoardStateController> boardState;
  final ChangeNotifierProvider<GroupStateController> groupState;
  final ScrollController boardScrollController;
  final ScrollConfig? groupScrollConfig;
  final ScrollConfig? boardScrollConfig;

  @override
  ConsumerState<DraggableOverlay> createState() => _DraggableOverlayState();
}

class _DraggableOverlayState extends ConsumerState<DraggableOverlay> {
  /// This method is called when the dragging widget position is updated.
  /// It makes use of [GroupScrollHandler] and [BoardScrollHandler] to check if the group or board should scroll.
  Future<void> _onDragUpdate() async {
    final boardState = ref.read(widget.boardState);
    final draggingState = boardState.draggingState;
    final groupState = ref.read(widget.groupState);

    if (draggingState.draggableType == DraggableType.none) return;

    /// Check if the group should scroll.
    await GroupScrollHandler.checkGroupScroll(
        boardState: boardState,
        scrollConfig: widget.groupScrollConfig,
        scrollController:
            boardState.groups[draggingState.currentGroupIndex].scrollController,
        isScrolling: groupState.isScrolling,
        setScrolling: (value) => groupState.setScrolling(value));

    /// Check if the board should scroll.
    await BoardScrollHandler.checkBoardScroll(
        boardState: boardState,
        scrollConfig: widget.boardScrollConfig,
        scrollController: widget.boardScrollController,
        isScrolling: boardState.isScrolling,
        setScrolling: (value) => boardState.setScrolling(value));
  }

  @override
  Widget build(BuildContext context) {
    final draggingState =
        ref.watch(widget.boardState.select((value) => value.draggingState));
    return ValueListenableBuilder(
      valueListenable: draggingState.feedbackOffset,
      builder: (ctx, Offset value, child) {
        _onDragUpdate();
        return draggingState.draggableType != DraggableType.none
            ? Positioned(
                left: value.dx,
                top: value.dy,
                child: Opacity(
                  opacity: 1,
                  child: draggingState.draggingWidget,
                ),
              )
            : Container();
      },
    );
  }
}

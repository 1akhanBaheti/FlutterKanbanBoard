import 'package:flutter/material.dart';
import 'package:kanban_board/src/board_inputs.dart';
import 'board_state_controller.dart';
import 'states/draggable_state.dart';

class ScrollHandler {
  static bool scrolling = false;

  void checkBoardScroll({
    required ScrollController boardScrollController,
    ScrollConfig? boardScrollConfig,
    required BoardStateController boardState,
  }) async {
    final draggingState = boardState.draggingState;

    /// If nothing is being dragged or scrolling is in progress, return.
    if ((draggingState.draggableType == DraggableType.none) || scrolling) {
      return;
    }

    if (boardScrollController.offset <
            boardScrollController.position.maxScrollExtent &&
        draggingState.feedbackOffset.value.dx +
                (draggingState.feedbackSize.width / 2) >
            boardScrollController.position.viewportDimension - 100) {
      scrolling = true;
      if (boardScrollConfig == null) {
        await boardScrollController.animateTo(
            boardScrollController.offset + 100,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear);
      } else {
        await boardScrollController.animateTo(
            boardScrollConfig.offset + boardScrollController.offset,
            duration: boardScrollConfig.duration,
            curve: boardScrollConfig.curve);
      }
      scrolling = false;
      checkBoardScroll(
        boardScrollController: boardScrollController,
        boardScrollConfig: boardScrollConfig,
        boardState: boardState,
      );
    } else if (boardScrollController.offset > 0 &&
        draggingState.feedbackOffset.value.dx <= 0) {
      scrolling = true;

      if (boardScrollConfig == null) {
        await boardScrollController.animateTo(
            boardScrollController.offset - 100,
            duration: Duration(
                milliseconds:
                    draggingState.feedbackOffset.value.dx < 20 ? 50 : 100),
            curve: Curves.linear);
      } else {
        await boardScrollController.animateTo(
            boardScrollController.offset - boardScrollConfig.offset,
            duration: boardScrollConfig.duration,
            curve: boardScrollConfig.curve);
      }
      scrolling = false;
      checkBoardScroll(
        boardScrollController: boardScrollController,
        boardScrollConfig: boardScrollConfig,
        boardState: boardState,
      );
    } else {
      return;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:kanban_board/src/helpers/scroll_configuration_helper.dart';
import 'board_state_controller.dart';
import 'states/board_internal_states.dart';
import 'states/draggable_state.dart';
import 'states/scroll_state.dart';

/// [ScrollHandler] is used when the user is dragging a group-item near the edge of the group-end.
/// It can variate the velocity of the scroll based on the distance of the draggable to the edge of the group.
class ScrollHandler {
  static Duration getDuration(
      ScrollVelocity velocity, ScrollConfig scrollConfig) {
    return velocity == ScrollVelocity.slow
        ? scrollConfig.farBoundary.duration
        : velocity == ScrollVelocity.medium
            ? scrollConfig.midBoundary.duration
            : scrollConfig.nearBoundary.duration;
  }

  static double getOffsetToMove(
      ScrollVelocity velocity, ScrollConfig scrollConfig) {
    return velocity == ScrollVelocity.fast
        ? scrollConfig.nearBoundary.offset
        : velocity == ScrollVelocity.medium
            ? scrollConfig.midBoundary.offset
            : scrollConfig.farBoundary.offset;
  }

  static ScrollVelocity getVelocity(
      AxisDirection axisDirection,
      double draggingWidgetPosition,
      double maxViewport,
      ScrollConfig scrollConfig) {
    if (axisDirection == AxisDirection.down ||
        axisDirection == AxisDirection.right) {
      return draggingWidgetPosition >
              maxViewport - scrollConfig.farBoundary.boundary
          ? ScrollVelocity.fast
          : draggingWidgetPosition >
                  maxViewport - scrollConfig.midBoundary.boundary
              ? ScrollVelocity.medium
              : ScrollVelocity.slow;
    } else {
      return draggingWidgetPosition < scrollConfig.farBoundary.boundary
          ? ScrollVelocity.fast
          : draggingWidgetPosition < scrollConfig.midBoundary.boundary
              ? ScrollVelocity.medium
              : ScrollVelocity.slow;
    }
  }

  static Future<void> _downsideScroll({
    required BoardStateController boardState,
    required ScrollConfig scrollConfig,
    required ScrollController scrollController,
    required bool isScrolling,
    required void Function(bool value) setScrolling,
  }) async {
    final draggingState = boardState.draggingState;

    /// If the draggable is not a group-item or the group is already scrolling, [return].
    /// This is to prevent the group from scrolling while the group is already scrolling.
    if (draggingState.draggableType != DraggableType.item || isScrolling) {
      return;
    }
    final draggingWidgetBottomPosition = draggingState.feedbackOffset.value.dy +
        draggingState.feedbackSize.height;

    /// The maximum viewport of the scroll controller.
    final scrollContext = scrollController.position.context.storageContext;
    final scrollRenderBox = scrollContext.findRenderObject() as RenderBox;
    final scrollStartPos = scrollRenderBox.localToGlobal(Offset.zero);
    final maxViewport = scrollController.position.viewportDimension +
        scrollStartPos.dy -
        boardState.boardOffset.dy;

    /// If the scroll controller is not at the end and the dragging widget is near the end of the viewport, scroll the controller.
    if (scrollController.offset < scrollController.position.maxScrollExtent &&
        draggingWidgetBottomPosition >
            maxViewport - scrollConfig.farBoundary.boundary) {
      setScrolling(true);

      /// [velocity] is used to determine the speed of the scroll.
      /// It is based on the distance of the dragging widget to the end of the viewport.
      final velocity = draggingWidgetBottomPosition >
              maxViewport - scrollConfig.nearBoundary.boundary
          ? ScrollVelocity.fast
          : draggingWidgetBottomPosition >
                  maxViewport - scrollConfig.midBoundary.boundary
              ? ScrollVelocity.medium
              : ScrollVelocity.slow;

      final offset = velocity == ScrollVelocity.fast
          ? scrollConfig.nearBoundary.offset
          : velocity == ScrollVelocity.medium
              ? scrollConfig.midBoundary.offset
              : scrollConfig.farBoundary.offset;

      final duration = velocity == ScrollVelocity.fast
          ? scrollConfig.nearBoundary.duration
          : velocity == ScrollVelocity.medium
              ? scrollConfig.midBoundary.duration
              : scrollConfig.farBoundary.duration;

      final jump = offset + scrollController.offset;

      scrollController
          .animateTo(
        jump,
        duration: duration,
        curve: scrollConfig.curve,
      )
          .then((_) {
        setScrolling(false);
        _downsideScroll(
            boardState: boardState,
            scrollConfig: scrollConfig,
            scrollController: scrollController,
            isScrolling: false,
            setScrolling: setScrolling);
      });
    }
    return;
  }

  static Future<void> _upsideScroll({
    required BoardStateController boardState,
    required ScrollConfig scrollConfig,
    required ScrollController scrollController,
    required bool isScrolling,
    required void Function(bool value) setScrolling,
  }) async {
    final draggingState = boardState.draggingState;

    /// If the draggable is not a group-item or the group is already scrolling, [return].
    /// This is to prevent the group from scrolling while the group is already scrolling.
    if (draggingState.draggableType != DraggableType.item || isScrolling) {
      return;
    }
    final draggingWidgetTopPosition = draggingState.feedbackOffset.value.dy;

    /// The minimum viewport of the scroll controller.
    final scrollContext = scrollController.position.context.storageContext;
    final scrollRenderBox = scrollContext.findRenderObject() as RenderBox;
    final scrollStartPos = scrollRenderBox.localToGlobal(Offset.zero);
    final minViewport = scrollStartPos.dy - boardState.boardOffset.dy;

    /// If the scroll controller is not at the start and the dragging widget is near the start of the viewport, scroll the controller.
    if (scrollController.offset > scrollController.position.minScrollExtent &&
        draggingWidgetTopPosition <
            minViewport + scrollConfig.farBoundary.boundary) {
      setScrolling(true);

      /// [velocity] is used to determine the speed of the scroll.
      /// It is based on the distance of the dragging widget to the end of the viewport.
      final velocity = draggingWidgetTopPosition <
              minViewport + scrollConfig.nearBoundary.boundary
          ? ScrollVelocity.fast
          : draggingWidgetTopPosition <
                  minViewport + scrollConfig.midBoundary.boundary
              ? ScrollVelocity.medium
              : ScrollVelocity.slow;

      final offset = velocity == ScrollVelocity.fast
          ? scrollConfig.nearBoundary.offset
          : velocity == ScrollVelocity.medium
              ? scrollConfig.midBoundary.offset
              : scrollConfig.farBoundary.offset;

      final duration = velocity == ScrollVelocity.fast
          ? scrollConfig.nearBoundary.duration
          : velocity == ScrollVelocity.medium
              ? scrollConfig.midBoundary.duration
              : scrollConfig.farBoundary.duration;

      final jump = scrollController.offset - offset;

      scrollController
          .animateTo(
        jump,
        duration: duration,
        curve: scrollConfig.curve,
      )
          .then((_) {
        setScrolling(false);
        _upsideScroll(
          boardState: boardState,
          scrollConfig: scrollConfig,
          scrollController: scrollController,
          isScrolling: false,
          setScrolling: setScrolling,
        );
      });
    }
    return;
  }

  static Future<void> _rightWayScroll({
    required BoardStateController boardState,
    required ScrollConfig scrollConfig,
    required ScrollController scrollController,
    required bool isScrolling,
    required void Function(bool value) setScrolling,
  }) async {
    final draggingState = boardState.draggingState;

    /// If the draggable is not a group-item or the group is already scrolling, [return].
    /// This is to prevent the group from scrolling while the group is already scrolling.
    if (draggingState.draggableType == DraggableType.none || isScrolling) {
      return;
    }

    final draggingWidgetRightPosition = draggingState.feedbackOffset.value.dx +
        draggingState.feedbackSize.width;

    /// The maximum viewport of the scroll controller.
    final scrollContext = scrollController.position.context.storageContext;
    final scrollRenderBox = scrollContext.findRenderObject() as RenderBox;
    final scrollStartPos = scrollRenderBox.localToGlobal(Offset.zero);
    final maxViewport = scrollController.position.viewportDimension +
        scrollStartPos.dx -
        boardState.boardOffset.dx;

    /// If the scroll controller is not at the end and the dragging widget is near the end of the viewport, scroll the controller.
    if (scrollController.offset < scrollController.position.maxScrollExtent &&
        draggingWidgetRightPosition >
            maxViewport - scrollConfig.farBoundary.boundary) {
      setScrolling(true);

      /// [velocity] is used to determine the speed of the scroll.
      /// It is based on the distance of the dragging widget to the end of the viewport.
      final velocity = draggingWidgetRightPosition >
              maxViewport - scrollConfig.nearBoundary.boundary
          ? ScrollVelocity.fast
          : draggingWidgetRightPosition >
                  maxViewport - scrollConfig.midBoundary.boundary
              ? ScrollVelocity.medium
              : ScrollVelocity.slow;
      final offset = velocity == ScrollVelocity.fast
          ? scrollConfig.nearBoundary.offset
          : velocity == ScrollVelocity.medium
              ? scrollConfig.midBoundary.offset
              : scrollConfig.farBoundary.offset;

      final duration = velocity == ScrollVelocity.fast
          ? scrollConfig.nearBoundary.duration
          : velocity == ScrollVelocity.medium
              ? scrollConfig.midBoundary.duration
              : scrollConfig.farBoundary.duration;

      final jump = offset + scrollController.offset;
      scrollController
          .animateTo(
        jump,
        duration: duration,
        curve: scrollConfig.curve,
      )
          .then((_) {
        setScrolling(false);
        _rightWayScroll(
          boardState: boardState,
          scrollConfig: scrollConfig,
          scrollController: scrollController,
          isScrolling: false,
          setScrolling: setScrolling,
        );
      });
    }
    return;
  }

  static Future<void> _leftWayScroll({
    required BoardStateController boardState,
    required ScrollConfig scrollConfig,
    required ScrollController scrollController,
    required bool isScrolling,
    required void Function(bool value) setScrolling,
  }) async {
    final draggingState = boardState.draggingState;

    /// If the draggable is not a group-item or the group is already scrolling, [return].
    /// This is to prevent the group from scrolling while the group is already scrolling.
    if (draggingState.draggableType == DraggableType.none || isScrolling) {
      return;
    }
    final draggingWidgetLeftPosition = draggingState.feedbackOffset.value.dx;

    /// The minimum viewport of the scroll controller.
    final minViewport = boardState.boardOffset.dx;

    /// If the scroll controller is not at the start and the dragging widget is near the start of the viewport, scroll the controller.
    if (scrollController.offset > scrollController.position.minScrollExtent &&
        draggingWidgetLeftPosition <
            minViewport + scrollConfig.farBoundary.boundary) {
      setScrolling(true);

      /// [velocity] is used to determine the speed of the scroll.
      /// It is based on the distance of the dragging widget to the end of the viewport.
      final velocity = draggingWidgetLeftPosition <
              minViewport + scrollConfig.nearBoundary.boundary
          ? ScrollVelocity.fast
          : draggingWidgetLeftPosition <
                  minViewport + scrollConfig.midBoundary.boundary
              ? ScrollVelocity.medium
              : ScrollVelocity.slow;

      final offset = velocity == ScrollVelocity.fast
          ? scrollConfig.nearBoundary.offset
          : velocity == ScrollVelocity.medium
              ? scrollConfig.midBoundary.offset
              : scrollConfig.farBoundary.offset;

      final duration = velocity == ScrollVelocity.fast
          ? scrollConfig.nearBoundary.duration
          : velocity == ScrollVelocity.medium
              ? scrollConfig.midBoundary.duration
              : scrollConfig.farBoundary.duration;

      final jump = scrollController.offset - offset;

      scrollController
          .animateTo(
        jump,
        duration: duration,
        curve: scrollConfig.curve,
      )
          .then((_) {
        setScrolling(false);
        _leftWayScroll(
          boardState: boardState,
          scrollConfig: scrollConfig,
          scrollController: scrollController,
          isScrolling: false,
          setScrolling: setScrolling,
        );
      });
      return;
    }
  }
}

class GroupScrollHandler {
  static Future<void> checkGroupScroll({
    required BoardStateController boardState,
    ScrollConfig? scrollConfig,
    required ScrollController scrollController,
    required bool isScrolling,
    required void Function(bool value) setScrolling,
  }) async {
    final defaultScrollConfig = PlatformScrollConfiguration.groupScrollConfig;
    await ScrollHandler._downsideScroll(
      boardState: boardState,
      scrollConfig: scrollConfig ?? defaultScrollConfig,
      scrollController: scrollController,
      isScrolling: isScrolling,
      setScrolling: setScrolling,
    );
    await ScrollHandler._upsideScroll(
      boardState: boardState,
      scrollConfig: scrollConfig ?? defaultScrollConfig,
      scrollController: scrollController,
      isScrolling: isScrolling,
      setScrolling: setScrolling,
    );
  }
}

class BoardScrollHandler {
  static Future<void> checkBoardScroll({
    required BoardStateController boardState,
    ScrollConfig? scrollConfig,
    required ScrollController scrollController,
    required bool isScrolling,
    required void Function(bool value) setScrolling,
  }) async {
    final defaultScrollConfig = PlatformScrollConfiguration.boardScrollConfig;
    await ScrollHandler._rightWayScroll(
      boardState: boardState,
      scrollConfig: scrollConfig ?? defaultScrollConfig,
      scrollController: scrollController,
      isScrolling: isScrolling,
      setScrolling: setScrolling,
    );
    await ScrollHandler._leftWayScroll(
      boardState: boardState,
      scrollConfig: scrollConfig ?? defaultScrollConfig,
      scrollController: scrollController,
      isScrolling: isScrolling,
      setScrolling: setScrolling,
    );
  }
}

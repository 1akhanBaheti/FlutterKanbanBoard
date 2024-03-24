import 'package:flutter/material.dart';
import 'package:kanban_board/src/constants/constants.dart';

/// [ScrollConfig] is used to configure the scroll behaviour.
class ScrollConfig {
  final Boundary nearBoundary;
  final Boundary midBoundary;
  final Boundary farBoundary;
  final Curve curve;

  const ScrollConfig({
    required this.nearBoundary,
    required this.midBoundary,
    required this.farBoundary,
    required this.curve,
  });
}

class GroupScrollConfig extends ScrollConfig {
  const GroupScrollConfig():super(
    nearBoundary: const _GroupNearBoundary(),
    midBoundary: const _GroupMidBoundary(),
    farBoundary: const _GroupFarBoundary(),
    curve: Curves.linear,
  );
}

class BoardScrollConfig extends ScrollConfig {
  const BoardScrollConfig():super(
    nearBoundary: const _BoardNearBoundary(),
    midBoundary: const _BoardMidBoundary(),
    farBoundary: const _BoardFarBoundary(),
    curve: Curves.linear,
  );
}

/// [Boundary] is used to define the boundary of the scroll, with its respective offset and duration.
class Boundary {
  /// [boundary] is the distance from the edge of the group.
  final double boundary;

  /// [offset] is the distance to be scrolled.
  final double offset;

  /// [duration] is the duration of the scroll.
  final Duration duration;

  const Boundary({
    required this.boundary,
    required this.offset,
    required this.duration,
  });
}

// Group Scroll Boundaries
class _GroupFarBoundary extends Boundary {
  const _GroupFarBoundary({
    double boundary = GROUP_FAR_SCROLL_BOUNDARY,
    double offset = GROUP_FAR_SCROLL_MOVE,
    Duration duration = GROUP_FAR_SCROLL_DURATION,
  }) : super(boundary: boundary, offset: offset, duration: duration);
}

class _GroupMidBoundary extends Boundary {
  const _GroupMidBoundary({
    double boundary = GROUP_MID_SCROLL_BOUNDARY,
    double offset = GROUP_MID_SCROLL_MOVE,
    Duration duration = GROUP_MID_SCROLL_DURATION,
  }) : super(boundary: boundary, offset: offset, duration: duration);
}

class _GroupNearBoundary extends Boundary {
  const _GroupNearBoundary({
    double boundary = GROUP_NEAR_SCROLL_BOUNDARY,
    double offset = GROUP_NEAR_SCROLL_MOVE,
    Duration duration = GROUP_NEAR_SCROLL_DURATION,
  }) : super(boundary: boundary, offset: offset, duration: duration);
}

// Board Scroll Boundaries

class _BoardFarBoundary extends Boundary {
  const _BoardFarBoundary({
    double boundary = BOARD_FAR_SCROLL_BOUNDARY,
    double offset = BOARD_FAR_SCROLL_MOVE,
    Duration duration = BOARD_FAR_SCROLL_DURATION,
  }) : super(boundary: boundary, offset: offset, duration: duration);
}

class _BoardMidBoundary extends Boundary {
  const _BoardMidBoundary({
    double boundary = BOARD_MID_SCROLL_BOUNDARY,
    double offset = BOARD_MID_SCROLL_MOVE,
    Duration duration = BOARD_MID_SCROLL_DURATION,
  }) : super(boundary: boundary, offset: offset, duration: duration);
}

class _BoardNearBoundary extends Boundary {
  const _BoardNearBoundary({
    double boundary = BOARD_NEAR_SCROLL_BOUNDARY,
    double offset = BOARD_NEAR_SCROLL_MOVE,
    Duration duration = BOARD_NEAR_SCROLL_DURATION,
  }) : super(boundary: boundary, offset: offset, duration: duration);
}

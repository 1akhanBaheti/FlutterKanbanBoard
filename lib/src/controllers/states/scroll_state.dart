import 'package:flutter/material.dart';

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
  const GroupScrollConfig({
    required Boundary nearBoundary,
    required Boundary midBoundary,
    required Boundary farBoundary,
    required Curve curve,
  }) : super(
          nearBoundary: nearBoundary,
          midBoundary: midBoundary,
          farBoundary: farBoundary,
          curve: curve,
        );
}

class BoardScrollConfig extends ScrollConfig {
  const BoardScrollConfig({
    required Boundary nearBoundary,
    required Boundary midBoundary,
    required Boundary farBoundary,
    required Curve curve,
  }) : super(
          nearBoundary: nearBoundary,
          midBoundary: midBoundary,
          farBoundary: farBoundary,
          curve: curve,
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
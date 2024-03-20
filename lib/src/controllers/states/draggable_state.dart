import 'package:flutter/material.dart';

/// [PlaceHolderAt] is used to determine the location of the placeholder widget.
enum PlaceHolderAt { top, bottom, none }

/// [DraggableType] is used to determine the type of the widget that is being dragged.
enum DraggableType { item, group, none }

/// It is used to manage the internal state of the [dragging-widget] widget.
class DraggableState {
  DraggableState({
    this.draggingWidget,
    this.draggableType = DraggableType.none,
    this.feedbackSize = Size.zero,
    this.dragStartIndex = -1,
    this.currentIndex = -1,
    this.dragStartGroupIndex = -1,
    this.currentGroupIndex = -1,
  });

  /// The widget currently being dragged.
  Widget? draggingWidget;

  /// The type [DraggableType] of the widget currently being dragged.
  DraggableType draggableType = DraggableType.none;

  /// The last computed size of the feedback widget being dragged.
  Size feedbackSize = Size.zero;

  /// The last computed offset of the feedback widget being dragged.
  ValueNotifier<Offset> feedbackOffset = ValueNotifier(Offset.zero);

  /// This is the last computed direction of the feedback widget being dragged.
  /// This value is updated on every pixel movement of the feedback widget.
  /// This value is used to determine the direction of the feedback widget, includes [AxisDirection.up], [AxisDirection.down], [AxisDirection.left], [AxisDirection.right].
  AxisDirection? axisDirection;

  /// The location that the dragging widget occupied before it started to drag.
  int dragStartIndex = -1;

  /// The index that the dragging widget currently occupies.
  int currentIndex = -1;

  /// The index of the group that the dragging widget started to drag from.
  int dragStartGroupIndex = -1;

  /// The index of the group that the dragging widget currently occupies.
  int currentGroupIndex = -1;

  /// It is set [DraggableState] to its initial state.
  factory DraggableState.initial() {
    return DraggableState(
      draggingWidget: null,
      draggableType: DraggableType.none,
      feedbackSize: Size.zero,
      dragStartIndex: -1,
      currentIndex: -1,
      dragStartGroupIndex: -1,
      currentGroupIndex: -1,
    );
  }

  /// It is used to update the state of the [DraggableState], with the new values.
  DraggableState updateWith({
    Widget? draggingWidget,
    DraggableType? draggableType,
    Size? feedbackSize,
    int? dragStartIndex,
    int? currentIndex,
    int? dragStartGroupIndex,
    int? currentGroupIndex,
  }) {
    this.draggingWidget = draggingWidget ?? this.draggingWidget;
    this.draggableType = draggableType ?? this.draggableType;
    this.feedbackSize = feedbackSize ?? this.feedbackSize;
    this.dragStartIndex = dragStartIndex ?? this.dragStartIndex;
    this.currentIndex = currentIndex ?? this.currentIndex;
    this.dragStartGroupIndex = dragStartGroupIndex ?? this.dragStartGroupIndex;
    this.currentGroupIndex = currentGroupIndex ?? this.currentGroupIndex;
    return this;
  }
}

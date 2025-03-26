import 'package:kanban_board/src/controllers/states/board_internal_states.dart';
import 'package:kanban_board/src/controllers/states/draggable_state.dart';

class GroupDragCoordinatesHelper {

  /// [canItemDropOverGroup] checks if the dragged item can be dropped on the group or not.
  /// It checks if the item is entering the group from the left or right side.
 static bool canItemDropOverGroup({
    required DraggableState draggingState,
    required IKanbanBoardGroup group,
  }) {
    final draggableOffset = draggingState.feedbackOffset.value;

    /// Check if the item is entering the group from the left side.
    /// Check if draggable is in the left 40% of the group width
    final bool isInLeftSide =
        draggableOffset.dx < group.position!.dx + (group.size.width * 0.4);

    /// Check if draggable extends past the right edge of the group
    final bool extendsRightEdge = group.position!.dx + group.size.width <
        draggingState.feedbackSize.width + draggableOffset.dx;

    /// Item is entering from left if both conditions are true
    final bool enteringFromLeft = isInLeftSide && extendsRightEdge;

    /// Check if draggable right edge is in right 60% of group width
    final bool isInRightSide =
        draggingState.feedbackSize.width + draggableOffset.dx >
            group.position!.dx + (group.size.width * 0.6);

    /// Check if draggable fits within group width
    final bool fitsInGroup = group.position!.dx + group.size.width >
        draggingState.feedbackSize.width + draggableOffset.dx;

    /// Item is entering from right if both conditions are true
    final bool enteringFromRight = isInRightSide && fitsInGroup;

    /// For item to change group, it should not be in the same group.
    return (enteringFromLeft || enteringFromRight);
  }
}

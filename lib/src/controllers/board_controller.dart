import 'package:flutter/material.dart';
import 'package:kanban_board/src/board_inputs.dart';
import 'package:kanban_board/src/helpers/board_state_controller_storage.dart';
import 'package:kanban_board/src/widgets/textfield.dart';
import 'package:uuid/uuid.dart';

import 'controllers.dart';

class KanbanBoardController {
  late final String boardId;

  /// [KanbanBoardController] controls the behavior of some operations in [KanbanBoard].
  /// operations include adding a [group], adding a [group-item], etc.
  KanbanBoardController() : boardId = const Uuid().v4();

  /// [addGroup] adds a group to the board.
  void addGroup(String id, dynamic groupData) {}

  /// [addGroupItem] adds a group-item to the board at a specific index. If the index is not provided, it will be added at the end.
  void addGroupItem({
    required String groupId,
    required KanbanBoardGroupItem groupItem,
    int? index,
  }) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    final group = boardController.groups.firstWhere(
        (element) => element.id == groupId,
        orElse: (() => throw Exception('Group not found')));

    group.items.insert(
      index ?? group.items.length,
      IKanbanBoardGroupItem(
        groupIndex: group.index,
        id: const Uuid().v4(),
        index: index ?? 0,
        key: GlobalKey(),
        addedBySystem: true,
        setState: () {},
      ),
    );

    group.setState();
  }

  /// [removeGroup] removes a group from the board.
  void removeGroup(String groupId) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    boardController.groups.removeWhere((element) => element.id == groupId);
    boardController.notify();
  }

  /// Removes a item from the group in the board.
  void removeGroupItem(String groupId, String itemId) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    final group = boardController.groups.firstWhere(
        (element) => element.id == groupId,
        orElse: (() => throw Exception('Group not found with id: $groupId')));

    group.items.removeWhere((element) => element.id == itemId);
    group.setState();
  }

  /// [showNewCard] shows a new card in the group.
  void showNewCard({
    required final String groupId,
    final int? position,
    final void Function(String)? onCardAdded,
  }) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    final group = boardController.groups.firstWhere(
        (element) => element.id == groupId,
        orElse: (() => throw Exception('Group not found')));

    group.items.insert(
      position ?? group.items.length,
      IKanbanBoardGroupItem(
        groupIndex: group.index,
        id: const Uuid().v4(),
        index: position ?? 0,
        key: GlobalKey(),
        addedBySystem: true,
        setState: () {},
        //TODO: Why ghost is used?
        ghost: 
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              height: 120,
              child: CardWithTextField(
                onCompleteEditing: (value){
                  group.items.removeAt(position ?? group.items.length);
                  onCardAdded?.call(value);
                }
              ),
            ),
      ),
    );

    group.setState();
  }
}

/// [KanbanBoardGroup] is used for Board's group input.
class KanbanBoardGroup<T, I extends KanbanBoardGroupItem> {
  /// It is the [id] of the group.
  /// Every group should have a unique id.
  String id;

  /// It is the [name] of the group.
  /// If headerWidget is not provided, this will be used to display the name of the group.
  String name;

  /// This is a [customData] that can be used to store any data.
  T? customData;

  /// This contains the list of [items] in the group.
  List<I> items = const [];

  KanbanBoardGroup({
    this.customData,
    required this.id,
    required this.name,
    this.items = const [],
  });
}

/// [KanbanBoardGroupItem] is used for Board's group item input.
abstract class KanbanBoardGroupItem {
  String get id;

  @override
  String toString() => 'KanbanBoardListItem(id: $id)';
}

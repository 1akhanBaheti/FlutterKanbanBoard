import 'package:flutter/material.dart';
import 'draggable_state.dart';

/// [IKanbanBoardGroup] is used to manage the internal state of the [Groups].
class IKanbanBoardGroup {
  /// The [id] of the group.
  String id;

  /// This stores the [name] of the group.
  String name;

  /// This is a [customData] that can be used to store any data.
  dynamic customData;

  /// It is the index of the group in the board.
  int index;

  /// It is the [key] of the group.
  /// This is used to identify the group and compute its position offset.
  GlobalKey key;

  /// This is the [ghost] widget that is used to show the dragging widget.
  Widget? ghost;

  /// [placeHolderAt] determines if the placeholder is attached to group or not, and its position.
  PlaceHolderAt placeHolderAt = PlaceHolderAt.none;

  /// It handles the group animation when dragging widget is near the group.
  AnimationController? animationController;

  late Offset animationOffset;

  /// This holds the last computed [position] of the group.
  Offset? position;

  /// This holds the last computed [size] of the group.
  Size size = Size.zero;

  /// This holds the last computed [actualSize] of the group.
  Size actualSize = Size.zero;

  /// [setState] is used to update the state of the group.
  /// It is often used to invoke rebuild of the widget.
  VoidCallback setState;

  /// This is the [scrollController] that is used to control the scroll of the group.
  /// It is used to scroll the group when the dragging widget is near the edge of the group.
  ScrollController scrollController = ScrollController();

  /// This contains the list of [items] in the group.
  List<IKanbanBoardGroupItem> items = const [];

  IKanbanBoardGroup({
    required this.id,
    required this.key,
    required this.name,
    required this.index,
    required this.setState,
    required this.scrollController,
    this.animationController,
    this.customData,
    this.ghost,
    this.items = const [],
    this.placeHolderAt = PlaceHolderAt.none,
    this.position,
    this.size = const Size(0, 0),
    this.actualSize = const Size(0, 0),
    this.animationOffset = Offset.zero,
  });

  IKanbanBoardGroup updateWith({
    String? id,
    GlobalKey? key,
    String? name,
    int? index,
    VoidCallback? setState,
    dynamic customData,
    Widget? ghost,
    Offset? position,
    Size? size,
    Size? actualSize,
    List<IKanbanBoardGroupItem>? items,
    Offset? animationOffset,
    PlaceHolderAt? placeHolderAt,
    ScrollController? scrollController,
    AnimationController? animationController,
  }) {
    this.id = id ?? this.id;
    this.key = key ?? this.key;
    this.name = name ?? this.name;
    this.index = index ?? this.index;
    this.setState = setState ?? this.setState;
    this.customData = customData ?? this.customData;
    this.ghost = ghost ?? this.ghost;
    this.position = position ?? this.position;
    this.size = size ?? this.size;
    this.actualSize = actualSize ?? this.actualSize;
    this.items = items ?? this.items;
    this.animationOffset = animationOffset ?? this.animationOffset;
    this.placeHolderAt = placeHolderAt ?? this.placeHolderAt;
    this.scrollController = scrollController ?? this.scrollController;
    this.animationController = animationController ?? this.animationController;
    return this;
  }

  IKanbanBoardGroup copyWith({
    String? id,
    GlobalKey? key,
    String? name,
    int? index,
    VoidCallback? setState,
    ScrollController? scrollController,
    AnimationController? animationController,
    dynamic customData,
    Widget? ghost,
    List<IKanbanBoardGroupItem>? items,
    PlaceHolderAt? placeHolderAt,
    Offset? position,
    Size? size,
    Size? actualSize,
    Offset? animationOffset,
  }) {
    return IKanbanBoardGroup(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      index: index ?? this.index,
      setState: setState ?? this.setState,
      scrollController: scrollController ?? this.scrollController,
      animationController: animationController ?? this.animationController,
      customData: customData ?? this.customData,
      ghost: ghost ?? this.ghost,
      items: items ?? this.items,
      placeHolderAt: placeHolderAt ?? this.placeHolderAt,
      position: position ?? this.position,
      size: size ?? this.size,
      actualSize: actualSize ?? this.actualSize,
      animationOffset: animationOffset ?? this.animationOffset,
    );
  }
}

/// [IKanbanBoardGroupItem] is used to manage the internal state of the [GroupItems].
class IKanbanBoardGroupItem {
  /// The [id] of the item.
  String id;

  /// It is the [index] of the item in the group.
  int index;

  /// It is the index of the group this item is associated with in the board.
  int groupIndex;

  /// This is the [key] of the item.
  /// This is used to identify the item and compute its position offset.
  GlobalKey key;

  /// This is the [ghost] widget that is used to show the dragging widget.
  Widget? ghost;

  /// This is the [itemWidget] that is used to show the item.
  Widget? itemWidget;

  /// This holds the last computed [position] of the item.
  Offset? position;

  /// [setState] is used to update the state of the group-item.
  /// It is often used to invoke rebuild of the widget.
  VoidCallback setState;

  /// This is used to determine if the item was added by the system.
  /// This is used when group is empty, and the system adds an item to it, to show the placeholder.
  bool addedBySystem = false;

  /// [placeHolderAt] used to determine if the placeholder is attached to item or not.
  /// This also defines the position of the placeholder. It can be at the start or at the end of the item.
  PlaceHolderAt placeHolderAt = PlaceHolderAt.none;

  /// This holds the last computed [size] of the item.
  /// This will be affected by the placeholder.
  Size size = Size.zero;

  /// This holds the last computed [actualSize] of the item.
  /// This will not be affected by the placeholder.
  Size actualSize = Size.zero;

  // This is used to animate the item when dragging widget is near the item.
  late AnimationController? animationController;

  IKanbanBoardGroupItem({
    required this.key,
    required this.id,
    required this.index,
    required this.setState,
    required this.groupIndex,
    this.ghost,
    this.itemWidget,
    this.position,
    this.size = const Size(0, 0),
    this.actualSize = const Size(0, 0),
    this.addedBySystem = false,
    this.placeHolderAt = PlaceHolderAt.none,
    this.animationController,
  });

  IKanbanBoardGroupItem updateWith({
    GlobalKey? key,
    String? id,
    int? index,
    int? groupIndex,
    VoidCallback? setState,
    Widget? ghost,
    Widget? itemWidget,
    PlaceHolderAt? placeHolderAt,
    Size? size,
    Size? actualSize,
    Offset? position,
  }) {
    this.key = key ?? this.key;
    this.id = id ?? this.id;
    this.index = index ?? this.index;
    this.groupIndex = groupIndex ?? this.groupIndex;
    this.setState = setState ?? this.setState;
    this.ghost = ghost ?? this.ghost;
    this.itemWidget = itemWidget ?? this.itemWidget;
    this.placeHolderAt = placeHolderAt ?? this.placeHolderAt;
    this.size = size ?? this.size;
    this.actualSize = actualSize ?? this.actualSize;
    this.position = position ?? this.position;
    return this;
  }
  
  IKanbanBoardGroupItem copyWith({
    GlobalKey? key,
    String? id,
    int? index,
    int? groupIndex,
    VoidCallback? setState,
    Widget? ghost,
    Widget? itemWidget,
    PlaceHolderAt? placeHolderAt,
    Size? size,
    Size? actualSize,
    Offset? position,
    AnimationController? animationController,
  }) {
    return IKanbanBoardGroupItem(
      key: key ?? this.key,
      id: id ?? this.id,
      index: index ?? this.index,
      groupIndex: groupIndex ?? this.groupIndex,
      setState: setState ?? this.setState,
      ghost: ghost ?? this.ghost,
      itemWidget: itemWidget ?? this.itemWidget,
      placeHolderAt: placeHolderAt ?? this.placeHolderAt,
      size: size ?? this.size,
      actualSize: actualSize ?? this.actualSize,
      position: position ?? this.position,
      animationController: animationController ?? this.animationController,
    );
  }
  @override
  String toString() {
    return 'IKanbanBoardGroupItem(key: $key, id: $id, index: $index, groupIndex: $groupIndex)';
  }

}

/// [GroupOperationType] is used to determine the type of operation to be performed on the group.
enum GroupOperationType { addItem, delete }

enum ScrollVelocity { slow, medium, fast }

import 'package:flutter/material.dart';

class ListItem {
  BuildContext? context;
  double height;
  double width;
  int listIndex;
  Color? backgroundColor;
  int index;
  double x;
  double y;
  Widget child;
  ListItem({
    this.context,
    required this.child,
    required this.listIndex,
    required this.index,
    required this.height,
    this.backgroundColor,
    required this.width,
    required this.x,
    required this.y,
  });
}

class DraggedItemState{
  BuildContext? context;
  double height;
  double width;
  int? listIndex;
  int? itemIndex;
  double x;
  VoidCallback? setState;
  double y;
  Widget child;
  DraggedItemState({
    this.context,
    required this.child,
    this.setState,
    required this.listIndex,
    required this.itemIndex,
    required this.height,
    required this.width,
    required this.x,
    required this.y,
  });
}

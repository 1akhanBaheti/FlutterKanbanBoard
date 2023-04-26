import 'package:flutter/material.dart';

class ListItem {
  BuildContext? context;
  double? height;
  double? width;
  int listIndex;
  VoidCallback? setState;
  bool? isNew;
  Color? backgroundColor;
  int index;
  double? x;
  double? y;
  Widget child;
  ListItem({
    this.context,
    required this.child,
    required this.listIndex,
    required this.index,
    this.height,
    this.setState,
    this.backgroundColor,
    this.width,
    this.x,
    this.y,
    this.isNew=false,
  });
}

class DraggedItemState {
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

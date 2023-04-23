import 'package:flutter/material.dart';

class ListItem {
  BuildContext? context;
  double height;
  double width;
  int listIndex;
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
    required this.width,
    required this.x,
    required this.y,
  });
}

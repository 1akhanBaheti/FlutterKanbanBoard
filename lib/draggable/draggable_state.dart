import 'package:flutter/material.dart';

enum DraggableType { card, list, none }

abstract class DraggableState {
  DraggableState(
      {required this.height,
      required this.width,
      required this.context,
      required this.widget,
      required this.currPos});
  final double height;
  final double width;
  Offset currPos;
  final BuildContext context;
  final Widget widget;

  void setViewPosition(Offset currPos) {
    this.currPos = currPos;
  }
}

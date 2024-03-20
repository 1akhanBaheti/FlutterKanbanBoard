import 'package:flutter/material.dart';

class WidgetDetailHelper {
  static Size getSize(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    return box.size;
  }

  static Offset getOffset(BuildContext context, Offset boardOffset) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    return Offset.zero;
  }
}

import 'package:flutter/material.dart';

import 'dragged_element.dart';

class BoardList {
  BuildContext? context;
  double? x;
  double? y;
  double? height;
  double? width;
  Widget? child;
  VoidCallback? setState;
  List<ListItem> items = [];
  ScrollController? scrollController;
  String title;
  BoardList(
      {required this.items,
      this.context,
      this.setState,
      this.x,
      this.child,
      this.y,
      required this.scrollController,
      required this.title});
}

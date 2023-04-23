import 'package:flutter/material.dart';

import 'dragged_element.dart';

class BoardList {
  BuildContext? context;
  double? x;
  double? y;
  double? height;
  double? width;
  List<ListItem> items = [];
  ScrollController? scrollController;
  String title;
  BoardList(
      {required this.items,
      this.context,
      this.x,
      this.y,
      required this.scrollController,
      required this.title});
}

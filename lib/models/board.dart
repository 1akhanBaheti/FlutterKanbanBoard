import 'package:boardview/models/board_list.dart';
import 'package:flutter/material.dart';

class Board {
  List<BoardList> lists = [];
  ScrollController controller;
  int? dragListIndex = 0;
  int? dragItemIndex = 0;
  int? dragItemOfListIndex = 0;
  bool isElementDragged = false;
  bool isListDragged = false;
  Board(
      {required this.lists,
      required this.controller,
      this.dragListIndex,
      this.dragItemIndex,
      this.dragItemOfListIndex,
      this.isElementDragged = false,
      this.isListDragged = false});
}

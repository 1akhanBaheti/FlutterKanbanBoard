import 'package:boardview/models/board_list.dart';
import 'package:flutter/material.dart';

class BoardState {
  List<BoardList> lists = [];
  ScrollController controller;
  int? dragListIndex = 0;
  int? dragItemIndex = 0;
  double? displacementX;
  double? displacementY;
  int? dragItemOfListIndex = 0;
  bool isElementDragged = false;
  bool isListDragged = false;
  TextEditingController newCardTextController = TextEditingController();
  bool? newCardFocused = false;
  int? newCardListIndex;
  int? newCardIndex;
  Function(int? itemIndex, int? listIndex)? onItemTap;
  Function(int? itemIndex, int? listIndex)? onItemLongPress;
  Function(int? listIndex)? onListTap;
  Function(int? listIndex)? onListLongPress;
  final void Function(int? oldCardIndex,int? newCardIndex, int? oldListIndex,int?newListIndex)? onItemReorder;
  final void Function(int? oldListIndex,int?newListIndex)? onListReorder;
  final void Function(String?oldName, String?newName)? onListRename;
  final void Function(String?cardIndex, String?listIndex, String?text)? onNewCardInsert;
  final Widget Function(Widget child,Animation<double> animation)? cardTransitionBuilder; 
  final Widget Function(Widget child,Animation<double> animation)? listTransitionBuilder;   
  Color? backgroundColor;
  Color? cardPlaceholderColor;
  Color? listPlaceholderColor;
  TextStyle? textStyle;
  Decoration? listDecoration;
  Decoration? boardDecoration;
  final Duration cardTransitionDuration;
  final Duration listTransitionDuration;
  BoardState(
      {required this.lists,
      required this.controller,
      this.dragListIndex,
      this.onItemTap,
      this.onItemLongPress,
      this.onListTap,
      this.onItemReorder,
      this.onListReorder,
      this.onListRename,
      this.onNewCardInsert,
      this.displacementX,
      this.displacementY,
      this.newCardIndex,
      this.newCardListIndex,
      this.onListLongPress,
      this.dragItemIndex,
      this.textStyle,
      this.backgroundColor = Colors.white,
      this.cardPlaceholderColor,
      this.listPlaceholderColor,
      this.cardTransitionBuilder,
      this.listTransitionBuilder,
      this.listDecoration,
      this.boardDecoration,
      this.dragItemOfListIndex,
      this.isElementDragged = false,
      this.cardTransitionDuration= const Duration(milliseconds: 150),
      this.listTransitionDuration= const Duration(milliseconds: 150),
      this.isListDragged = false}) {
    textStyle = textStyle ??
        TextStyle(
            color: Colors.grey.shade800,
            fontSize: 19,
            fontWeight: FontWeight.w400);

  }
}

import 'package:flutter/material.dart';
import 'item_state.dart';

class BoardList {
  BuildContext? context;
  double? x;
  double? y;
  double? height;
  double? width;
  Widget? child;
  Widget? header;
  Widget? footer;
  Color? headerBackgroundColor;
  Color? footerBackgroundColor;
  Color? backgroundColor;
  VoidCallback? setState;
  List<ListItem> items = [];
  TextEditingController nameController=TextEditingController();
  ScrollController scrollController;

  String title;
  BoardList(
      {required this.items,
      this.context,
      this.height,
      this.width,
      this.header,
      this.footer,
      this.setState,
      this.headerBackgroundColor,
      this.footerBackgroundColor,
      this.x,
      this.child,
      this.backgroundColor = Colors.white,
      this.y,
      required this.scrollController,
      required this.title}){
    headerBackgroundColor = headerBackgroundColor ?? Colors.grey.shade300;
    footerBackgroundColor = footerBackgroundColor ?? Colors.grey.shade300;
  }
}

import 'package:flutter/material.dart';
import 'package:kanban_board/src/constants/constants.dart';

import '../controllers/controllers.dart';

class DefaultStyles {
  static TextStyle textStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
        fontFamily: "Raleway",
        fontSize: fontSize ?? 16,
        color: color ?? Colors.black,
        fontWeight: fontWeight ?? FontWeight.normal);
  }

  static Widget groupHeader({
    required IKanbanBoardGroup group,
    required Function(GroupOperationType type) onOperationSelect,
  }) {
    return Container(
      width: DEFAULT_GROUP_WIDTH,
      padding: const EdgeInsets.only(bottom: 10, top: 10, right: 0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            group.name,
            style: textStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget groupFooter({
    required Function() onAddNewGroup,
  }) {
    return Container(
      width: DEFAULT_GROUP_WIDTH,
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          IconButton(
            onPressed: onAddNewGroup,
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
          Text(
            "New",
            style: textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static groupItemGhost() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
    );
  }
}

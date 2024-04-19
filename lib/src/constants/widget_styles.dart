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

  static BoxDecoration groupDecoration() {
    return BoxDecoration(
      color: Color.fromRGBO(247, 248, 249, 1),
      borderRadius: const BorderRadius.all(Radius.circular(5)),
    );
  }

  static Widget groupHeader({
    required IKanbanBoardGroup group,
    required Function(GroupOperationType type) onOperationSelect,
  }) {
    return Container(
      width: DEFAULT_GROUP_WIDTH,
      decoration: groupDecoration(),
      padding: const EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            group.name,
            style: textStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
              // padding: const EdgeInsets.all(5),
              child: PopupMenuButton(
                  color: Colors.white,
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                    size: 18,
                  ),
                  itemBuilder: (ctx) {
                    return [
                      PopupMenuItem(
                        value: GroupOperationType.addItem,
                        child: Text(
                          "Add item",
                          style: textStyle(),
                        ),
                      ),
                      PopupMenuItem(
                        value: GroupOperationType.delete,
                        child: Text(
                          "Delete Group",
                          style: textStyle(),
                        ),
                      ),
                    ];
                  },
                  onSelected: (value) => onOperationSelect(value))),
        ],
      ),
    );
  }

  static Widget groupFooter({
    required Function() onAddNewGroup,
  }) {
    return Container(
      width: DEFAULT_GROUP_WIDTH,
      decoration: groupDecoration(),
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

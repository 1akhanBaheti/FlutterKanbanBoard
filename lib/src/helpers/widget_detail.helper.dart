import 'package:flutter/material.dart';
import 'package:kanban_board/src/board.dart';
import 'package:kanban_board/src/constants/widget_styles.dart';
import 'package:kanban_board/src/controllers/controllers.dart';

class WidgetHelper {
  static Widget getDraggingGroup(
      {required BuildContext context,
      required IKanbanBoardGroup group,
      required int groupIndex,
      GroupHeaderBuilder? header,
      GroupFooterBuilder? footer}) {
    return SizedBox(
      height: group.size.height,
      width: group.size.width,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        /// This builds the header of the group.
        /// If the [GroupHeaderBuilder] is not provided, then it uses the default header.
        header != null
            ? header(context, group.id)
            : DefaultStyles.groupHeader(group: group, onOperationSelect: (_) {}),
      
        /// This builds the body of the group.
        /// This renders the list of items in the group.
        Flexible(
          child: ListView.builder(
            itemCount: group.items.length,
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              return group.items[index].itemWidget;
            },
          ),
        ),
      
        /// This builds the footer of the group.
        /// If the [GroupFooterBuilder] is not provided, then it uses the default footer.
        footer != null
            ? footer(context, group.id)
            : DefaultStyles.groupFooter(onAddNewGroup: () => {})
      ]),
    );
  }
}

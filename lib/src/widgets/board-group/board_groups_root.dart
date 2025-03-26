import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/controllers/group_state_controller.dart';
import 'package:kanban_board/src/controllers/board_state_controller.dart';
import 'package:kanban_board/src/controllers/group_item_state_controller.dart';
import 'package:kanban_board/src/board.dart';
import 'board_group.dart';

class BoardGroupsRoot extends ConsumerStatefulWidget {
  const BoardGroupsRoot({
    required this.boardStateController,
    required this.groupItemBuilder,
    required this.leading,
    required this.trailing,
    required this.groupConstraints,
    required this.groupDecoration,
    required this.groupItemStateController,
    required this.groupStateController,
    required this.boardScrollController,
    this.header,
    this.footer,
    super.key,
  });

  final ChangeNotifierProvider<BoardStateController> boardStateController;
  final ChangeNotifierProvider<GroupItemStateController>
      groupItemStateController;
  final ChangeNotifierProvider<GroupStateController> groupStateController;
  final ScrollController boardScrollController;
  final Widget? trailing;
  final Widget? leading;
  final BoxConstraints groupConstraints;
  final Decoration? groupDecoration;
  final GroupItemBuilder groupItemBuilder;
  final GroupHeaderBuilder? header;
  final GroupFooterBuilder? footer;

  @override
  ConsumerState<BoardGroupsRoot> createState() => _BoardGroupsRootState();
}

class _BoardGroupsRootState extends ConsumerState<BoardGroupsRoot> {

  @override
  Widget build(BuildContext context) {
    final groups =
        ref.watch(widget.boardStateController.select((value) => value.groups));
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      child: SingleChildScrollView(
        controller: widget.boardScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            widget.leading ?? Container(),
            ...[
              for (int index = 0; index < groups.length; index++)
                BoardGroup(
                  groupItemStateController: widget.groupItemStateController,
                  groupStateController: widget.groupStateController,
                  header: widget.header,
                  footer: widget.footer,
                  itemBuilder: widget.groupItemBuilder,
                  groupDecoration: widget.groupDecoration,
                  boardStateController: widget.boardStateController,
                  groupIndex: index,
                  groupConstraints: widget.groupConstraints,
                ),
            ],
            widget.trailing ?? Container(),
          ],
        ),
      ),
    );
  }
}

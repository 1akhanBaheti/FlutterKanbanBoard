import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/src/constants/constants.dart';
import 'package:kanban_board/src/controllers/controllers.dart';

class GroupPlaceholderWrapper extends ConsumerStatefulWidget {
  const GroupPlaceholderWrapper(
      {required this.groupIndex,
      required this.groupStateController,
      required this.boardStateController,
      required this.child,
      super.key});
  final int groupIndex;
  final ChangeNotifierProvider<GroupStateController> groupStateController;
  final ChangeNotifierProvider<BoardStateController> boardStateController;
  final Widget child;
  @override
  ConsumerState<GroupPlaceholderWrapper> createState() =>
      _GroupPlaceholderWrapperState();
}

class _GroupPlaceholderWrapperState
    extends ConsumerState<GroupPlaceholderWrapper>
    with TickerProviderStateMixin {
  late AnimationController? _animationController;

  @override
  void initState() {
    final group =
        ref.read(widget.boardStateController).groups[widget.groupIndex];

    group.animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    group.animationOffset = Offset(
        group.placeHolderAt == PlaceHolderAt.left
            ? -1
            : group.placeHolderAt == PlaceHolderAt.right
                ? 1
                : 0,
        0);
    _animationController = group.animationController;

    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.read(widget.boardStateController);
    final draggingState = boardState.draggingState;
    final group = boardState.groups[widget.groupIndex];

    return Row(
      children: [
        group.placeHolderAt == PlaceHolderAt.left
            ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutSine,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Opacity(
                  opacity: 0.6,
                  child: Container(
                    margin: const EdgeInsets.only(right: LIST_GAP),
                    child: draggingState.draggingWidget,
                  ),
                ))
            : Container(),
        SlideTransition(
            position: Tween<Offset>(
                    begin: group.animationOffset, end: const Offset(0, 0))
                .animate(
              CurvedAnimation(
                parent: _animationController!,
                curve: _animationController!.isAnimating
                    ? Curves.easeOutSine
                    : Curves.ease,
              ),
            ),
            child: widget.child),
        group.placeHolderAt == PlaceHolderAt.right
            ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutSine,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Opacity(
                    opacity: 0.6,
                    child: Container(
                      margin: const EdgeInsets.only(right: LIST_GAP),
                      child: draggingState.draggingWidget,
                    )))
            : Container(),
      ],
    );
  }
}

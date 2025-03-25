import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/Provider/provider_list.dart';
import 'package:kanban_board/draggable/draggable_state.dart';

class DraggedCard extends ConsumerStatefulWidget {
  const DraggedCard({super.key});

  @override
  ConsumerState<DraggedCard> createState() => _DraggedCardState();
}

class _DraggedCardState extends ConsumerState<DraggedCard> {
  @override
  Widget build(BuildContext context) {
    final boardProv = ref.read(ProviderList.boardProvider);
    final boardListProv = ref.read(ProviderList.boardListProvider);
    final draggableProv = ref.watch(ProviderList.draggableNotifier);

    return ValueListenableBuilder(
      valueListenable: boardProv.valueNotifier,
      builder: (ctx, Offset value, child) {
        if (draggableProv.isCardDragged) {
          boardListProv.maybeListScroll();
        }
        return draggableProv.draggableType != DraggableType.none
            ? Positioned(
                left: value.dx,
                top: value.dy,
                child: Opacity(
                  opacity: 0.4,
                  child: boardProv.draggedItemState!.child,
                ),
              )
            : Container();
      },
    );
  }
}

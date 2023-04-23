import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Provider/provider_list.dart';

class Item extends ConsumerStatefulWidget {
  const Item(
      {super.key,
      required this.itemIndex,
      required this.listIndex,
      required this.widget});
  final int itemIndex;
  final int listIndex;
  final Widget widget;
  @override
  ConsumerState<Item> createState() => _ItemState();
}

class _ItemState extends ConsumerState<Item>
    with AutomaticKeepAliveClientMixin {
  Offset location = Offset.zero;
  bool newAdded = false;

  @override
  Widget build(BuildContext context) {
    // if (location == null) {
    var prov = ref.read(ProviderList.reorderProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      prov.board.lists[widget.listIndex].items[widget.itemIndex].context =
          context;
      var box = context.findRenderObject() as RenderBox;
      location = box.localToGlobal(Offset.zero);
      prov.board.lists[widget.listIndex].items[widget.itemIndex].x =
          location.dx;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].y =
          location.dy;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].width =
          box.size.width;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].height =
          box.size.height;
    });
    return GestureDetector(
        onLongPress: () {
          var box = context.findRenderObject() as RenderBox;
          location = box.localToGlobal(Offset.zero);
          prov.updateValue(dx: location.dx, dy: location.dy - 24);
          prov.board.dragItemIndex = widget.itemIndex;
          prov.board.dragItemOfListIndex = widget.listIndex;
          prov.setcanDrag(
              value: true,
              itemIndex: widget.itemIndex,
              listIndex: widget.listIndex);
        },
        child: AnimatedSwitcher(
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          duration: const Duration(milliseconds: 300),
          child: prov.board.isElementDragged &&
                  prov.board.dragItemOfListIndex ==
                      prov.board.lists[widget.listIndex].items[widget.itemIndex]
                          .listIndex &&
                  prov.board.dragItemIndex == widget.itemIndex

                  
              ? Container(
                key: ValueKey(widget.itemIndex),
                width: 300, child: widget.widget)
              : Container(width: 300, child: widget.widget),
        )

        //  widget.index == prov.itemIndex
        //     ? const Opacity(opacity: 1)
        //   :
        );
  }

  @override
  bool get wantKeepAlive => true;
}

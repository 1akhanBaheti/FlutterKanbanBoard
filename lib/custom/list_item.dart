import 'package:boardview/custom/text_field.dart';
import 'package:boardview/models/item_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Provider/provider_list.dart';

class Item extends ConsumerStatefulWidget {
  const Item({
    super.key,
    required this.itemIndex,
    this.color = Colors.pink,
    required this.listIndex,
  });
  final int itemIndex;
  final int listIndex;
  final Color color;
  @override
  ConsumerState<Item> createState() => _ItemState();
}

class _ItemState extends ConsumerState<Item>
    with AutomaticKeepAliveClientMixin {
  Offset location = Offset.zero;
  bool newAdded = false;
  var node = FocusNode();
  @override
  Widget build(BuildContext context) {
    super.build(context);

    var prov = ref.read(ProviderList.reorderProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!context.mounted) return;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].context =
          context;
      var box = context.findRenderObject() as RenderBox;
      location = box.localToGlobal(Offset.zero);
      prov.board.lists[widget.listIndex].items[widget.itemIndex].setState =
          () => setState(() {});
      prov.board.lists[widget.listIndex].items[widget.itemIndex].x =
          location.dx-prov.board.displacementX!;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].y =
          location.dy - prov.board.displacementY!;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].width =
          box.size.width;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].height =
          box.size.height;
    });
    return GestureDetector(
      onLongPress: () {
        var box = context.findRenderObject() as RenderBox;
        location = box.localToGlobal(Offset.zero);
        prov.board.lists[widget.listIndex].items[widget.itemIndex].x =
            location.dx-prov.board.displacementX!;
        prov.board.lists[widget.listIndex].items[widget.itemIndex].y =
            location.dy - prov.board.displacementY!;
        prov.board.lists[widget.listIndex].items[widget.itemIndex].width =
            box.size.width;
        prov.board.lists[widget.listIndex].items[widget.itemIndex].height =
            box.size.height;
        prov.updateValue(
            dx: location.dx-prov.board.displacementX!, dy: location.dy - prov.board.displacementY!);
        prov.board.dragItemIndex = widget.itemIndex;
        prov.board.dragItemOfListIndex = widget.listIndex;
        prov.board.isElementDragged = true;
        prov.draggedItemState = DraggedItemState(
            child: Container(
              color: prov.board.lists[widget.listIndex].items[widget.itemIndex]
                      .backgroundColor ??
                  Colors.white,
              width: box.size.width - 20,
              child: prov
                  .board.lists[widget.listIndex].items[widget.itemIndex].child,
            ),
            listIndex: widget.listIndex,
            itemIndex: widget.itemIndex,
            height: box.size.height,
            width: box.size.width,
            x: location.dx,
            y: location.dy);
        prov.draggedItemState!.setState =
            prov.board.lists[widget.listIndex].setState;
        setState(() {});
        // prov.notifyListeners();
      },
      child: AnimatedSwitcher(
        transitionBuilder: (child, animation) =>
            prov.board.cardTransitionBuilder != null
                ? prov.board.cardTransitionBuilder!(child, animation)
                : FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
        //  layoutBuilder: (currentChild, previousChildren) => currentChild!,
        duration: prov.board.cardTransitionDuration,
        child: prov.board.isElementDragged &&
                prov.board.dragItemOfListIndex == widget.listIndex &&
                prov.board.dragItemIndex == widget.itemIndex
            ? Container(
                //  key: UniqueKey(),
                color: prov.board.lists[widget.listIndex].items.length - 1 ==
                        widget.itemIndex
                    ? prov.board.cardPlaceholderColor ??
                        Colors.white.withOpacity(0.8)
                    : prov.board.cardPlaceholderColor ?? Colors.transparent,
                width: prov.draggedItemState!.width,
                height: prov.draggedItemState!.height,
                margin: const EdgeInsets.only(
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                child: prov.board.lists[widget.listIndex].items.length - 1 ==
                        widget.itemIndex
                    ? prov.board.cardPlaceholderColor != null
                        ? null
                        : Opacity(
                            opacity: 0.6, child: prov.draggedItemState!.child)
                    : null,
              )
            : prov.board.lists[widget.listIndex].items[widget.itemIndex]
                        .isNew ==
                    true
                ? Container(
                    width: prov.board.lists[widget.listIndex].width,
                    color: prov.board.lists[widget.listIndex].items[0]
                            .backgroundColor ??
                        Colors.white,
                    margin:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: const TField())
                : Container(
                    // key: UniqueKey(),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(6),
                      color: prov.board.lists[widget.listIndex]
                              .items[widget.itemIndex].backgroundColor ??
                          Colors.white,
                    ),
                    margin:
                        const EdgeInsets.only(bottom: 15, left: 10, right: 10),
                    width: prov.board.lists[widget.listIndex]
                        .items[widget.itemIndex].width,
                    child: prov.board.lists[widget.listIndex]
                        .items[widget.itemIndex].child,
                  ),
      ),

      //  widget.index == prov.itemIndex
      //     ? const Opacity(opacity: 1)
      //   :
    );
  }

  @override
  bool get wantKeepAlive => true;
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Provider/provider_list.dart';
import '../models/item_state.dart';
import 'list_item.dart';

class BoardList extends ConsumerStatefulWidget {
  const BoardList({super.key, required this.index});
  final int index;

  @override
  ConsumerState<BoardList> createState() => _BoardListState();
}

class _BoardListState extends ConsumerState<BoardList> {
  Offset location = Offset.zero;

  @override
  Widget build(BuildContext context) {
    var prov = ref.read(ProviderList.reorderProvider);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // log(prov.board.lists[widget.index].scrollController.hashCode.toString());
      prov.board.lists[widget.index].context = context;
      var box = context.findRenderObject() as RenderBox;
      location = box.localToGlobal(Offset.zero);
      prov.board.lists[widget.index].x =
          location.dx - prov.board.displacementX!;
      prov.board.lists[widget.index].setState = () => setState(() {});
      prov.board.lists[widget.index].y =
          location.dy - prov.board.displacementY!;
      // prov.board.lists[widget.index].width = box.size.width;
      prov.board.lists[widget.index].height = box.size.height;
    });
    return Container(
      margin: const EdgeInsets.only(right: 30, top: 20, bottom: 15),
      width: prov.board.lists[widget.index].width!,
      decoration: prov.board.listDecoration ??
          BoxDecoration(
              color: prov.board.lists[widget.index].backgroundColor,
              borderRadius: BorderRadius.circular(6)),
      child: AnimatedSwitcher(
        transitionBuilder: (child, animation) =>
            prov.board.listTransitionBuilder != null
                ? prov.board.cardTransitionBuilder!(child, animation)
                : FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
        //  layoutBuilder: (currentChild, previousChildren) => currentChild!,
        duration: prov.board.listTransitionDuration,

        child: prov.board.isListDragged &&
                prov.draggedItemState!.listIndex == widget.index
            ? Container(
                key: ValueKey(
                  "PLACEHOLDER ${widget.index}",
                ),
                color: prov.board.lists.length - 1 == widget.index
                    ? prov.board.listPlaceholderColor ??
                        Colors.white.withOpacity(0.8)
                    : prov.board.listPlaceholderColor ?? Colors.transparent,
                child: prov.board.lists.length - 1 == widget.index
                    ? prov.board.listPlaceholderColor != null
                        ? null
                        : Opacity(
                            opacity: 0.6, child: prov.draggedItemState!.child)
                    : null,
              )
            : Column(key: ValueKey("LIST ${widget.index}"), children: [
                GestureDetector(
                  onLongPress: () {
                    for (var element in prov.board.lists) {
                      if (element.context == null) break;
                      var of =
                          (element.context!.findRenderObject() as RenderBox)
                              .localToGlobal(Offset.zero);
                      element.x = of.dx - prov.board.displacementX!;
                      element.width = element.context!.size!.width-30;
                      element.height = element.context!.size!.height-30;
                      element.y = of.dy - prov.board.displacementY!;
                    }
                    var box = context.findRenderObject() as RenderBox;
                    location = box.localToGlobal(Offset.zero);
                    prov.updateValue(
                        dx: location.dx - prov.board.displacementX!-10,
                        dy: location.dy - prov.board.displacementY!+24);

                    prov.board.dragItemIndex = null;
                    prov.board.dragItemOfListIndex = widget.index;
                    prov.draggedItemState = DraggedItemState(
                        child: Container(
                          width: box.size.width-30,
                          height: box.size.height-30,
                          color: prov.board.lists[widget.index].backgroundColor,
                          child: Column(children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 20,
                              ),
                              padding:
                                  const EdgeInsets.only(left: 15, bottom: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                prov.board.lists[widget.index].title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  controller: null,
                                  itemCount: prov
                                      .board.lists[widget.index].items.length,
                                  shrinkWrap: true,
                                  itemBuilder: (ctx, index) {
                                    return Item(
                                      color: prov.board.lists[widget.index]
                                              .items[index].backgroundColor ??
                                          Colors.grey.shade200,
                                      itemIndex: index,
                                      listIndex: widget.index,
                                    );
                                  },

                                  // itemCount: prov.items.length,
                                ),
                              ),
                            ),
                          ]),
                        ),
                        listIndex: widget.index,
                        itemIndex: null,
                        height: box.size.height-30,
                        width: box.size.width-30,
                        x: location.dx - prov.board.displacementX!,
                        y: location.dy - prov.board.displacementY!);
                    prov.draggedItemState!.setState = () => setState(() {});
                    prov.board.dragItemIndex = null;
                    prov.board.isListDragged = true;
                    prov.board.dragItemOfListIndex = widget.index;
                    setState(() {});
                  },
                  child: Container(
                    width: prov.board.lists[widget.index].width,
                    color: prov.board.lists[widget.index].headerBackgroundColor,
                    margin: const EdgeInsets.only(bottom: 0),
                    padding: const EdgeInsets.only(
                        left: 15, bottom: 10, top: 10, right: 0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prov.board.lists[widget.index].title,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                            // padding: const EdgeInsets.all(5),
                            child: PopupMenuButton(
                                constraints: BoxConstraints(
                                  minWidth:
                                      prov.board.lists[widget.index].width! *
                                          0.7,
                                  maxWidth:
                                      prov.board.lists[widget.index].width! *
                                          0.7,
                                ),
                                itemBuilder: (ctx) {
                                  return [
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text(
                                        "Add card",
                                        style: prov.board.textStyle,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 2,
                                      child: Text(
                                        "Delete List",
                                        style: prov.board.textStyle,
                                      ),
                                    ),
                                  ];
                                },
                                onSelected: (value) {
                                  if (value == 1) {
                                    prov.board.lists[widget.index].items.insert(
                                        0,
                                        ListItem(
                                            child: const Text("New Item"),
                                            isNew: true,
                                            listIndex: widget.index,
                                            index: 0));
                                    prov.board.newCardListIndex = widget.index;
                                    prov.board.newCardIndex = 0;
                                    prov.board.newCardFocused = true;
                                    prov.board.lists[widget.index].setState!();
                                  } else if (value == 2) {
                                    prov.board.lists.removeAt(widget.index);
                                    prov.board.lists[widget.index].setState!();
                                  }
                                })),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      controller:
                          prov.board.lists[widget.index].scrollController,
                      itemCount: prov.board.lists[widget.index].items.length,
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        return Item(
                          itemIndex: index,
                          listIndex: widget.index,
                        );
                      },

                      // itemCount: prov.items.length,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15),
                  height: 45,
                  width: prov.board.lists[widget.index].width,
                  color: prov.board.lists[widget.index].footerBackgroundColor,
                  child: GestureDetector(
                    onTap: () async {
                      prov.board.lists[widget.index].items.add(ListItem(
                          child: const Text("NEW ITEM"),
                          listIndex: widget.index,
                          isNew: true,
                          index: prov.board.lists[widget.index].items.length));
                      var scroll =
                          prov.board.lists[widget.index].scrollController;
                      await scroll.animateTo(scroll.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.linear);
                      prov.board.newCardListIndex = widget.index;
                      prov.board.newCardFocused = true;
                      prov.board.newCardIndex =
                          prov.board.lists[widget.index].items.length - 1;
                      prov.board.lists[widget.index].setState!();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.grey.shade800,
                          size: 22,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'NEW',
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 19,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              ]),
      ),
    );
  }
}

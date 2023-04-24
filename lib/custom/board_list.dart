import 'dart:developer';

import 'package:boardview/custom/item.dart';
import 'package:boardview/models/dragged_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Provider/provider_list.dart';

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
    var prov = ref.watch(ProviderList.reorderProvider);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // log(prov.board.lists[widget.index].scrollController.hashCode.toString());
      prov.board.lists[widget.index].context = context;
      var box = context.findRenderObject() as RenderBox;
      location = box.localToGlobal(Offset.zero);
      prov.board.lists[widget.index].x = location.dx;
      prov.board.lists[widget.index].setState = () => setState(() {});
      prov.board.lists[widget.index].y = location.dy;
      prov.board.lists[widget.index].width = box.size.width;
      prov.board.lists[widget.index].height = box.size.height;
    });
    return Container(
      margin: const EdgeInsets.only(right: 15, top: 20),
      width: 200,
      height: 700,
      color: Colors.grey.shade300,
      child: AnimatedSwitcher(
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        //  layoutBuilder: (currentChild, previousChildren) => currentChild!,
        duration: const Duration(milliseconds: 100),
    
        child: prov.board.isListDragged &&
                prov.draggedItemState!.listIndex == widget.index
            ? Container()
            : Column(
              children: [
                GestureDetector(
                  onLongPress: () {
                    for (var element in prov.board.lists) {
                      if (element.context == null) break;
                      var of =
                          (element.context!.findRenderObject() as RenderBox)
                              .localToGlobal(Offset.zero);
                      element.x = of.dx;
                      element.width = element.context!.size!.width;
                      element.y = of.dy;
                    }
                    var box = context.findRenderObject() as RenderBox;
                    location = box.localToGlobal(Offset.zero);
                    prov.updateValue(dx: location.dx, dy: location.dy - 24);
                
                    prov.board.dragItemIndex = null;
                    prov.board.dragItemOfListIndex = widget.index;
                    prov.draggedItemState = DraggedItemState(
                        child: Container(
                          margin: const EdgeInsets.only(right: 50, top: 20),
                          width: 300,
                          height: 500,
                          color: Colors.grey.shade300,
                          child: Column(children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 15,
                              ),
                              padding:
                                  const EdgeInsets.only(left: 15, bottom: 15),
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
                                        color: Colors.amber,
                                        itemIndex: index,
                                        listIndex: widget.index,
                                        widget: prov.board.lists[widget.index]
                                            .items[index].child);
                                  },
                
                                  // itemCount: prov.items.length,
                                ),
                              ),
                            ),
                          ]),
                        ),
                        listIndex: widget.index,
                        itemIndex: null,
                        height: box.size.height,
                        width: 250,
                        x: location.dx,
                        y: location.dy);
                    prov.draggedItemState!.setState = () => setState(() {});
                    prov.board.dragItemIndex = null;
                    prov.board.isListDragged = true;
                    prov.board.dragItemOfListIndex = widget.index;
                  },
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.only(
                      top: 0,
                    ),
                    padding:
                        const EdgeInsets.only(left: 15, bottom: 15, top: 15),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      prov.board.lists[widget.index].title,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
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
                            widget: prov
                                .board.lists[widget.index].items[index].child);
                      },
                
                      // itemCount: prov.items.length,
                    ),
                  ),
                ),
              ]),
      ),
    );
  }
}

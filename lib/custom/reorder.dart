import 'dart:developer';
import 'package:boardview/custom/board_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Provider/provider_list.dart';
import '../models/dragged_element.dart';

class Reorder extends ConsumerStatefulWidget {
  const Reorder({super.key});
  @override
  ConsumerState<Reorder> createState() => _ReorderState();
}

class _ReorderState extends ConsumerState<Reorder> {
  var list = List.generate(20, (index) => index).toList();
  bool scrolling = false;
  bool scrollingUp = false;
  bool scrollingDown = false;
  @override
  void initState() {
    var prov = ref.read(ProviderList.reorderProvider);
    prov.board.controller.addListener(() {
      if (scrolling) {
        ListItem? closest;
        double closestDistance = double.infinity;
        // log("CALLED");
        if (scrollingDown) {
       for (var i = prov.draggedItemState!.index; i < prov.board.lists[prov.draggedItemState!.listIndex].items.length; i++) {
            var element = prov.board.lists[prov.draggedItemState!.listIndex].items[i];
            double val = prov.valueNotifier.value.dy;
            // if (element.y < val) continue;
            if (element.context == null) break;
            //log("ELEMENT Y = ${element.itemIndex}");
            var of = (element.context!.findRenderObject() as RenderBox)
                .localToGlobal(Offset.zero);
            element.x = of.dx;
            element.y = of.dy;
            if (closestDistance == double.infinity ||
                closestDistance > (val - element.y).abs()) {
              closest = element;
              closestDistance = (val - element.y).abs();
            }
          }
          moveDown(null);
        } else {
          for (var i = 0; i <= prov.draggedItemState!.index; i++) {
            var element = prov.board.lists[prov.draggedItemState!.listIndex].items[i];
            double val = prov.valueNotifier.value.dy;
            // if (element.y < val) continue;
            if (element.context == null) break;
            // log("ELEMENT Y = ${element.itemIndex}");
            var of = (element.context!.findRenderObject() as RenderBox)
                .localToGlobal(Offset.zero);
            element.x = of.dx;
            element.y = of.dy;
            if (closestDistance == double.infinity ||
                closestDistance > (val - element.y).abs()) {
              closest = element;
              closestDistance = (val - element.y).abs();
            }
          }
          moveUp();
        }
      }
    });
    super.initState();
  }

  void maybeScroll() async {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.board.isElementDragged == false || scrolling) {
      return;
    }
    if (prov.board.controller.offset < prov.board.controller.position.maxScrollExtent &&
        prov.valueNotifier.value.dy >
            prov.board.controller.position.viewportDimension - 100) {
      scrolling = true;
      scrollingDown = true;
      await prov.board.controller.animateTo(prov.board.controller.offset + 40,
          duration: const Duration(milliseconds: 400), curve: Curves.linear);

      scrolling = false;
      maybeScroll();
    } else if (prov.board.controller.offset > 0 &&
        prov.valueNotifier.value.dy < 100) {
      scrolling = true;
      scrollingUp = true;
      await prov.board.controller.animateTo(prov.board.controller.offset - 40,
          duration: Duration(
              milliseconds: prov.valueNotifier.value.dy < 50 ? 100 : 300),
          curve: Curves.linear);
      scrolling = false;
      maybeScroll();
    } else {
      return;
    }
  }

  void moveDown(ListItem? element) {
    // if (element == null) {
    //   log("RETURNED");
    //   return;
    // }
    var prov = ref.read(ProviderList.reorderProvider);
    double position = 0.0;
    if (prov.board.dragItemIndex! + 1 >=
        prov.board.lists[prov.board.dragItemOfListIndex!].items.length) {
      return;
    }
    if (prov.board.controller.position.pixels <= 0 || true) {
      position = prov.board.lists[prov.board.dragItemOfListIndex!]
          .items[prov.board.dragItemIndex!+1].y;
    }
    // if (prov.controller.offset < prov.controller.position.maxScrollExtent &&
    //     prov.valueNotifier.value.dy >
    //         prov.controller.position.viewportDimension - 200) {
    //   if (prov.valueNotifier.value.dy + 50 > position &&
    //       prov.valueNotifier.value.dy + 50 < position + 130) {
    //     prov.itemIndex = prov.itemIndex! + 1;
    //   }
    //   log("DOWN INDEX = ${prov.itemIndex} ");
    //   return;
    // }
    if (prov.valueNotifier.value.dy + 50 > position &&
        prov.valueNotifier.value.dy + 50 < position + 130) {
      log("here");
      prov.board.lists[prov.board.dragItemOfListIndex!].items
          .removeAt(prov.board.dragItemIndex!);
      prov.board.lists[prov.board.dragItemOfListIndex!].items.insert(
          prov.board.dragItemIndex! + 1,
          ListItem(
              child: Container(
                width: 500,
                // key: ValueKey("xlwq${prov.itemIndex! + 1}"),
                color: Colors.green,
                height: 50,
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "ITEM ${prov.draggedItemState!.index + 1}",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              listIndex: prov.board.dragItemOfListIndex!,
              index: prov.board.dragItemIndex! + 1,
              height: prov.board.lists[prov.board.dragItemOfListIndex!]
                  .items[prov.board.dragItemIndex!].height,
              width: prov.board.lists[prov.board.dragItemOfListIndex!]
                  .items[prov.board.dragItemIndex!].width,
              x: 0,
              y: 0));
      prov.board.dragItemIndex = prov.board.dragItemIndex! + 1;
      prov.setsState();
    }
  }

  void moveUp() {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.draggedItemState!.index == 0) {
      return;
    }
    // if (prov.controller.offset < prov.controller.position.maxScrollExtent &&
    //     prov.valueNotifier.value.dy >
    //         prov.controller.position.viewportDimension - 150) {
    //   //moveDown();
    //   return;
    // }
    log("UP INDEX = ${prov.draggedItemState!.index} ${prov.board.lists[prov.draggedItemState!.listIndex].items[prov.draggedItemState!.index - 1].y}");
    if (prov.valueNotifier.value.dy < prov.board.lists[prov.draggedItemState!.listIndex].items[prov.draggedItemState!.index - 1].y &&
        prov.valueNotifier.value.dy + 50 <
            prov.board.lists[prov.draggedItemState!.listIndex].items[prov.draggedItemState!.index - 1].y + 100) {
      prov.board.lists[prov.draggedItemState!.listIndex].items.removeAt(prov.draggedItemState!.index);
      // newAdded = true;
     prov.board.lists[prov.draggedItemState!.listIndex].items.insert(
          prov.draggedItemState!.index - 1,
          ListItem(
              child: Container(width: 500, color: Colors.green, height: 50),
              listIndex: 0,
              index: prov.draggedItemState!.index - 1,
              height:prov.board.lists[prov.draggedItemState!.listIndex].items[prov.draggedItemState!.index].height,
              width: prov.board.lists[prov.draggedItemState!.listIndex].items[prov.draggedItemState!.index].width,
              x: 0,
              y: 0));
      prov.draggedItemState!.index = prov.draggedItemState!.index - 1;

      log("UP 1");
      prov.setsState();
    }
  }

  @override
  Widget build(BuildContext context) {
    var prov = ref.watch(ProviderList.reorderProvider);
    return WillPopScope(
      onWillPop: () async {
        //  ref.read(ProviderList.reorderProvider).controller.dispose();
        return true;
      },
      child: Scaffold(
        body: Listener(
          onPointerUp: (event) {
            log("CANCELLED");
            if (prov.board.isElementDragged) {
              // var temp = prov.items[0];
              // prov.items.removeAt(0);
              // prov.items.insert(5, temp);
              prov.setcanDrag(value: false,listIndex: 0,itemIndex: 0);
            }
          },
          onPointerMove: (event) {
            if (prov.board.isElementDragged) {
              if (event.delta.dy > 0) {
                moveDown(null);
              } else {
                moveUp();
              }
              prov.valueNotifier.value = Offset(
                  event.delta.dx + prov.valueNotifier.value.dx,
                  event.delta.dy + prov.valueNotifier.value.dy);
              // if (prov.controller.offset != prov.prevScrollOffset) {
              //   prov.prevScrollOffset = prov.controller.offset;
              //   prov.setsState();
              // }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            child: Stack(
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      width: MediaQuery.of(context).size.width - 20,
                      child: SingleChildScrollView(
                        controller: prov.board.controller,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            //controller: prov.controller,
                            //  itemCount: prov.board.lists.length,
                            //shrinkWrap: true,
                            //   scrollDirection: Axis.horizontal,
                            //   itemBuilder: (ctx, listIndex) {
                            //     print("LIST ITEMS = ${prov.board.lists[listIndex].items.length}");
                            children: prov.board.lists
                                .map((e) => BoardList(
                                    index: prov.board.lists.indexOf(e),
                                    ))
                                .toList()
                            // },

                            // itemCount: prov.items.length,
                            ),
                      ),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(left: 50),
                    //   width: 300,
                    //   child: ListView.builder(
                    //     controller: prov.controller2,
                    //     itemCount: prov.items2.length,
                    //     shrinkWrap: true,
                    //     itemBuilder: (ctx, index) {
                    //       return Item(
                    //           index: index, widget: prov.items2[index].child);
                    //     },

                    //     // itemCount: prov.items.length,
                    //   ),
                    // ),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: prov.valueNotifier,
                  builder: (ctx, Offset value, child) {
                    if (prov.board.isElementDragged) {
                      maybeScroll();
                    }

                    return prov.board.isElementDragged
                        ? Positioned(
                            left: value.dx,
                            top: value.dy,
                            child: Opacity(
                              opacity: 0.6,
                              child: Container(
                                height: 50,
                                width: 250,
                                color: Colors.amber,
                              ),
                            ),
                          )
                        : Container();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

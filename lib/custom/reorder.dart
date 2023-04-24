import 'dart:developer' as dev;
import 'dart:math';
import 'package:boardview/custom/board_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoom_widget/zoom_widget.dart';
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
  bool scrollingLeft = false;
  bool scrollingRight = false;
  @override
  void initState() {
    var prov = ref.read(ProviderList.reorderProvider);
    for (var element in prov.board.lists) {
      element.scrollController!.addListener(() {
        if (scrolling) {
          ListItem? closest;
          double closestDistance = double.infinity;
          // log("CALLED");
          if (scrollingDown) {
            for (var i = prov.board.dragItemIndex!;
                i <
                    prov.board.lists[prov.board.dragItemOfListIndex!].items
                        .length;
                i++) {
              var element =
                  prov.board.lists[prov.board.dragItemOfListIndex!].items[i];
              if (element.context == null) break;
              var of = (element.context!.findRenderObject() as RenderBox)
                  .localToGlobal(Offset.zero);
              element.x = of.dx;
              element.y = of.dy;
            }
            moveDown(null);
          } else {
            for (var i = 0;
                i <=
                    min(
                        prov.board.dragItemIndex! + 10,
                        prov.board.lists[prov.board.dragItemOfListIndex!].items
                            .length);
                i++) {
              var element =
                  prov.board.lists[prov.board.dragItemOfListIndex!].items[i];
              if (element.context == null) break;
              var of = (element.context!.findRenderObject() as RenderBox)
                  .localToGlobal(Offset.zero);
              element.x = of.dx;
              element.y = of.dy;
            }
            moveUp();
          }
        }
      });
    }
    prov.board.controller.addListener(() {
      if (scrolling) {
        if (scrollingLeft && prov.board.isElementDragged)
          moveLeft();
        else if (scrollingRight && prov.board.isElementDragged)
          moveRight();
        else if (scrollingLeft && prov.board.isListDragged) {
          for (var element in prov.board.lists) {
              if (element.context == null) break;
              var of = (element.context!.findRenderObject() as RenderBox)
                  .localToGlobal(Offset.zero);
              element.x = of.dx;
              element.width = element.context!.size!.width;
              element.y = of.dy;
          }
          moveListLeft();
        } else if (scrollingRight && prov.board.isListDragged) {
          for (var element in prov.board.lists) {
              if (element.context == null) break;
              var of = (element.context!.findRenderObject() as RenderBox)
                  .localToGlobal(Offset.zero);
              element.x = of.dx;
              element.width = element.context!.size!.width;
              element.y = of.dy;
          }
          moveListRight();
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
    var controller =
        prov.board.lists[prov.board.dragItemOfListIndex!].scrollController!;
    if (controller.offset < controller.position.maxScrollExtent &&
        prov.valueNotifier.value.dy >
            controller.position.viewportDimension - 100) {
      scrolling = true;
      scrollingDown = true;
      await controller.animateTo(controller.offset + 40,
          duration: const Duration(milliseconds: 400), curve: Curves.linear);

      scrolling = false;

      maybeScroll();
    } else if (controller.offset > 0 && prov.valueNotifier.value.dy < 100) {
      scrolling = true;
      scrollingUp = true;
      await controller.animateTo(controller.offset - 40,
          duration: Duration(
              milliseconds: prov.valueNotifier.value.dy < 50 ? 100 : 300),
          curve: Curves.linear);
      scrolling = false;
      maybeScroll();
    } else {
      return;
    }
  }

  void boardScroll() async {
    var prov = ref.read(ProviderList.reorderProvider);
    if ((prov.board.isElementDragged == false &&
            prov.board.isListDragged == false) ||
        scrolling) {
      return;
    }
    if (prov.board.controller.offset <
            prov.board.controller.position.maxScrollExtent &&
        prov.valueNotifier.value.dx + (prov.draggedItemState!.width / 2) >
            prov.board.controller.position.viewportDimension - 100) {
      scrolling = true;
      scrollingRight = true;
      await prov.board.controller.animateTo(prov.board.controller.offset + 30,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
      scrolling = false;
      scrollingRight = false;
      boardScroll();
    } else if (prov.board.controller.offset > 0 &&
        prov.valueNotifier.value.dx <= 0) {
      scrolling = true;
      scrollingLeft = true;
      await prov.board.controller.animateTo(prov.board.controller.offset - 30,
          duration: Duration(
              milliseconds: prov.valueNotifier.value.dx < 20 ? 50 : 100),
          curve: Curves.linear);
      scrolling = false;
      scrollingLeft = false;
      boardScroll();
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

    if (prov.valueNotifier.value.dx >
        prov.board.lists[prov.board.dragItemOfListIndex!].x! +
            (prov.board.lists[prov.board.dragItemOfListIndex!].width! / 2)) {
      return;
    }

    position = prov.board.lists[prov.board.dragItemOfListIndex!]
        .items[prov.board.dragItemIndex! + 1].y;

    if (prov.valueNotifier.value.dy + 50 > position &&
        prov.valueNotifier.value.dy + 50 < position + 130) {
      //dev.log("DOWN ${prov.board.dragItemOfListIndex}");
      prov.board.lists[prov.board.dragItemOfListIndex!].items
          .removeAt(prov.board.dragItemIndex!);
      prov.board.lists[prov.board.dragItemOfListIndex!].items.insert(
          prov.board.dragItemIndex! + 1,
          ListItem(
            backgroundColor: Colors.green,
              child: Text(
                "ITEM ${prov.board.dragItemIndex! + 1}",
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
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
      // prov.board.lists[prov.board.dragItemOfListIndex!].context!.findAncestorStateOfType()!.setState(() {

      // });
      prov.board.lists[prov.board.dragItemOfListIndex!].setState!();
    }
  }

  void moveUp() {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.board.dragItemIndex == 0) {
      return;
    }
    // log("UP INDEX = ${prov.draggedItemState!.index} ${prov.board.lists[prov.draggedItemState!.listIndex].items[prov.draggedItemState!.index - 1].y}");
    if (prov.valueNotifier.value.dy <
            prov.board.lists[prov.board.dragItemOfListIndex!]
                .items[prov.board.dragItemIndex! - 1].y &&
        prov.valueNotifier.value.dy + 50 <
            prov.board.lists[prov.board.dragItemOfListIndex!]
                    .items[prov.board.dragItemIndex! - 1].y +
                100) {
      prov.board.lists[prov.board.dragItemOfListIndex!].items
          .removeAt(prov.board.dragItemIndex!);
      // newAdded = true;
      prov.board.lists[prov.board.dragItemOfListIndex!].items.insert(
          prov.board.dragItemIndex! - 1,
          ListItem(
              backgroundColor: Colors.green,
              child: Text(
                "ITEM ${prov.board.dragItemIndex! + 1}",
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              listIndex: 0,
              index: prov.board.dragItemIndex!,
              height: prov.draggedItemState!.height,
              width: prov.draggedItemState!.width,
              x: 0,
              y: 0));
      prov.board.dragItemIndex = prov.board.dragItemIndex! - 1;

      dev.log("UP 1");
      prov.board.lists[prov.board.dragItemOfListIndex!].setState!();
    }
  }

  void moveRight() {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.draggedItemState!.listIndex == prov.board.lists.length - 1) {
      return;
    }

    ListItem? closest;
    double closestDistance = double.infinity;

    if (prov.valueNotifier.value.dx +
            prov.board.controller.offset +
            (prov.board.lists[prov.board.dragItemOfListIndex!].width! / 2) <
        prov.board.lists[prov.board.dragItemOfListIndex! + 1].x!) {
     // dev.log(
     //     "RIGHT RETURN ${prov.valueNotifier.value.dx + (prov.board.lists[prov.board.dragItemOfListIndex!].width! / 2)} ${prov.board.lists[prov.board.dragItemOfListIndex! + 1].x!}");
      return;
    }
    dev.log("RIGHT");

    for (var i = 0;
        i < prov.board.lists[prov.board.dragItemOfListIndex! + 1].items.length;
        i++) {
      var element =
          prov.board.lists[prov.board.dragItemOfListIndex! + 1].items[i];
      double val = prov.valueNotifier.value.dy;
      // if (element.y < val) continue;
      if (element.context == null ||
          element.y > MediaQuery.of(context).size.height) break;
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
    // if (prov.valueNotifier.value.dx >
    //     prov.board.lists[prov.draggedItemState!.listIndex + 1].x! +
    //         (prov.board.lists[prov.draggedItemState!.listIndex + 1].width! /
    //             2)) {
    prov.board.lists[prov.board.dragItemOfListIndex!].items
        .removeAt(prov.board.dragItemIndex!);
    prov.board.lists[prov.board.dragItemOfListIndex! + 1].items.insert(
        closest!.index,
        ListItem(
            child: Container(width: 500, color: Colors.green, height: 40),
            listIndex: prov.board.dragItemOfListIndex! + 1,
            index: closest.index,
            height: prov.board.lists[prov.board.dragItemOfListIndex!]
                .items[prov.board.dragItemIndex!].height,
            width: prov.board.lists[prov.board.dragItemOfListIndex!]
                .items[prov.board.dragItemIndex!].width,
            x: 0,
            y: 0));
    prov.draggedItemState!.listIndex = prov.board.dragItemOfListIndex! + 1;
    prov.board.dragItemOfListIndex = prov.draggedItemState!.listIndex;
    prov.board.dragItemIndex = closest.index;
    prov.draggedItemState!.itemIndex = closest.index;
    prov.board.lists[prov.draggedItemState!.listIndex! - 1].setState!();
    prov.board.lists[prov.draggedItemState!.listIndex!].setState!();
  }

  void moveLeft() {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.draggedItemState!.listIndex == 0) {
      return;
    }

    ListItem? closest;
    double closestDistance = double.infinity;
    if (prov.valueNotifier.value.dx + prov.board.controller.offset >
        prov.board.lists[prov.board.dragItemOfListIndex! - 1].x! +
            prov.board.lists[prov.board.dragItemOfListIndex! - 1].width! / 2) {
      return;
    }
    dev.log("LEFT");

    for (var i = 0;
        i < prov.board.lists[prov.board.dragItemOfListIndex! - 1].items.length;
        i++) {
      var element =
          prov.board.lists[prov.board.dragItemOfListIndex! - 1].items[i];
      double val = prov.valueNotifier.value.dy;
      // if (element.y < val) continue;
      if (element.context == null ||
          element.y > MediaQuery.of(context).size.height) break;
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
    // if (prov.valueNotifier.value.dx >
    //     prov.board.lists[prov.draggedItemState!.listIndex + 1].x! +
    //         (prov.board.lists[prov.draggedItemState!.listIndex + 1].width! /
    //             2)) {
    prov.board.lists[prov.board.dragItemOfListIndex!].items
        .removeAt(prov.board.dragItemIndex!);
    prov.board.lists[prov.board.dragItemOfListIndex! - 1].items.insert(
        closest!.index,
        ListItem(
            child: Container(width: 500, color: Colors.green, height: 40),
            listIndex: prov.board.dragItemOfListIndex! - 1,
            index: closest.index,
            height: prov.board.lists[prov.board.dragItemOfListIndex!]
                .items[prov.board.dragItemIndex!].height,
            width: prov.board.lists[prov.board.dragItemOfListIndex!]
                .items[prov.board.dragItemIndex!].width,
            x: 0,
            y: 0));
    prov.draggedItemState!.listIndex = prov.board.dragItemOfListIndex! - 1;
    prov.board.dragItemOfListIndex = prov.draggedItemState!.listIndex;
    prov.board.dragItemIndex = closest.index;
    prov.board.dragItemIndex = closest.index;
    prov.board.lists[prov.board.dragItemOfListIndex! + 1].setState!();
    prov.board.lists[prov.board.dragItemOfListIndex!].setState!();
    // }
  }

  void moveListRight() {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.draggedItemState!.listIndex == prov.board.lists.length - 1) {
      return;
    }
    if (prov.valueNotifier.value.dx +
           
            prov.board.lists[prov.draggedItemState!.listIndex!].width! / 2 <
        prov.board.lists[prov.draggedItemState!.listIndex! + 1].x!) {
      return;
    }
    dev.log("LIST RIGHT");
    prov.board.lists.insert(prov.draggedItemState!.listIndex! + 1,
        prov.board.lists.removeAt(prov.draggedItemState!.listIndex!));
    prov.draggedItemState!.listIndex = prov.draggedItemState!.listIndex! + 1;
    prov.board.dragItemOfListIndex = null;
    prov.board.dragItemIndex = null;
    prov.draggedItemState!.itemIndex = null;
    prov.board.lists[prov.draggedItemState!.listIndex! - 1].setState!();
    prov.board.lists[prov.draggedItemState!.listIndex!].setState!();
  }

  void moveListLeft() {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.draggedItemState!.listIndex == 0) {
      return;
    }
    if (prov.valueNotifier.value.dx >
        prov.board.lists[prov.draggedItemState!.listIndex! - 1].x! +
            (prov.board.lists[prov.draggedItemState!.listIndex! - 1].width! /
                2)) {
      // dev.log(
          // "RETURN LEFT LIST ${prov.valueNotifier.value.dx} ${prov.board.lists[prov.draggedItemState!.listIndex! - 1].x! + (prov.board.lists[prov.draggedItemState!.listIndex! - 1].width! / 2)} ");
      return;
    }
    // dev.log("LIST LEFT ${prov.valueNotifier.value.dx} ${prov.board.lists[prov.draggedItemState!.listIndex! - 1].x! + (prov.board.lists[prov.draggedItemState!.listIndex! - 1].width! / 2)} ");
    prov.board.lists.insert(prov.draggedItemState!.listIndex! - 1,
        prov.board.lists.removeAt(prov.draggedItemState!.listIndex!));
    prov.draggedItemState!.listIndex = prov.draggedItemState!.listIndex! - 1;
    prov.board.dragItemOfListIndex = null;
    prov.board.dragItemIndex = null;
    prov.draggedItemState!.itemIndex = null;
    prov.board.lists[prov.draggedItemState!.listIndex!].setState!();
    prov.board.lists[prov.draggedItemState!.listIndex! + 1].setState!();
  }

  @override
  Widget build(BuildContext context) {
    var prov = ref.read(ProviderList.reorderProvider);
    return WillPopScope(
      onWillPop: () async {
        //  ref.read(ProviderList.reorderProvider).controller.dispose();
        return true;
      },
      child: Scaffold(
        body: Listener(
          onPointerUp: (event) {
            dev.log("CANCELLED");
            if (prov.board.isElementDragged || prov.board.isListDragged) {
              setState(() {
                prov.setcanDrag(value: false, listIndex: 0, itemIndex: 0);
              });
            }
          },
          onPointerMove: (event) {
            if (prov.board.isElementDragged) {
              if (event.delta.dy > 0) {
                moveDown(null);
              } else {
                moveUp();
              }
              if (event.delta.dx > 0) {
                boardScroll();
                moveRight();
              } else {
                boardScroll();
                moveLeft();
              }
              prov.valueNotifier.value = Offset(
                  event.delta.dx + prov.valueNotifier.value.dx,
                  event.delta.dy + prov.valueNotifier.value.dy);
            } else if (prov.board.isListDragged) {
              if (event.delta.dx > 0) {
                boardScroll();
                moveListRight();
              } else {
                boardScroll();
                moveListLeft();
              }
              prov.valueNotifier.value = Offset(
                  event.delta.dx + prov.valueNotifier.value.dx,
                  event.delta.dy + prov.valueNotifier.value.dy);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            child: Stack(
              clipBehavior: Clip.none,
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
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: prov.valueNotifier,
                  builder: (ctx, Offset value, child) {
                    if (prov.board.isElementDragged) {
                      maybeScroll();
                    }
                    return prov.board.isElementDragged ||
                            prov.board.isListDragged
                        ? Positioned(
                            left: value.dx,
                            top: value.dy,
                            child: Opacity(
                              opacity: 0.6,
                              child: prov.draggedItemState!.child,
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

import 'dart:developer';
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

class _ItemState extends ConsumerState<Item> {
  Offset location = Offset.zero;
  bool newAdded = false;
  var node = FocusNode();
  @override
  Widget build(BuildContext context) {
    // log("BUILDED ${widget.itemIndex}");
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
          location.dx - prov.board.displacementX!;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].y =
          location.dy - prov.board.displacementY!;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].actualSize ??=
          box.size;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].width =
          box.size.width;
      prov.board.lists[widget.listIndex].items[widget.itemIndex].height =
          box.size.height;
    });
    return ValueListenableBuilder(
        valueListenable: prov.valueNotifier,
        builder: (ctx, a, b) {
          if (prov.board.isElementDragged == true) {
            var item =
                prov.board.lists[widget.listIndex].items[widget.itemIndex];
            var list = prov.board.lists[widget.listIndex];
            var box = context.findRenderObject();
            var listBox = list.context!.findRenderObject();
            if (box == null || listBox == null) return b!;

            box = box as RenderBox;
            listBox = listBox as RenderBox;
            location = box.localToGlobal(Offset.zero);
            item.x = location.dx - prov.board.displacementX!;
            item.y = location.dy - prov.board.displacementY!;
            item.setState = () => setState(() {});
            item.actualSize ??= box.size;

            // log("EXECUTED");
            item.width = box.size.width;
            item.height = box.size.height;

            list.x = listBox.localToGlobal(Offset.zero).dx -
                prov.board.displacementX!;
            list.y = listBox.localToGlobal(Offset.zero).dy -
                prov.board.displacementY!;

            if (prov.draggedItemState!.itemIndex == widget.itemIndex &&
                prov.draggedItemState!.listIndex == widget.listIndex) return b!;
            var condition = (widget.itemIndex ==
                    prov.board.lists[widget.listIndex].items.length - 1 &&
                ((prov.draggedItemState!.height * 0.1) +
                        prov.valueNotifier.value.dy >
                    item.y! + item.height!));
            var upsideCondition = (((prov.draggedItemState!.height * 0.6) +
                        prov.valueNotifier.value.dy <
                    item.y! + item.height!) &&
                (prov.draggedItemState!.height + prov.valueNotifier.value.dy >
                    item.y! + item.height!));

            if (((upsideCondition || condition || false
                        // ((widget.itemIndex == prov.board.lists[widget.listIndex].items.length - 1) &&
                        //     (prov.valueNotifier.value.dy < item.y!) &&
                        //        (prov.draggedItemState!.height +
                        //                 prov.valueNotifier.value.dy >
                        //             item.y!))
                        ) &&
                        prov.board.dragItemOfListIndex! == widget.listIndex) &&
                    (prov.board.dragItemIndex != widget.itemIndex ||
                        (condition &&
                            !prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].bottomPlaceholder!) ||
                        (prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].bottomPlaceholder! &&
                            widget.itemIndex ==
                                prov.board.lists[widget.listIndex].items.length -
                                    1))
                //    prov.board.dragItemIndex != widget.itemIndex
                // (prov.board.dragItemIndex != widget.itemIndex ||
                //     (condition &&
                //         !prov.board.lists[widget.listIndex]
                //             .items[widget.itemIndex].bottomPlaceholder!) ||
                //     (prov.board.lists[widget.listIndex].items[widget.itemIndex].bottomPlaceholder! &&
                //         widget.itemIndex ==
                //             prov.board.lists[widget.listIndex].items.length -
                //                 1))
                ) {
              // if (((upsideCondition ||
              //                     condition ||
              //                     (widget.itemIndex == prov.board.lists[widget.listIndex].items.length - 1 &&
              //                         (prov.valueNotifier.value.dy < item.y! &&
              //                             prov.draggedItemState!.height + prov.valueNotifier.value.dy >
              //                                 item.y!))) &&
              //                 prov.board.dragItemOfListIndex! == widget.listIndex) &&
              //             (prov.board.dragItemIndex != widget.itemIndex ||
              //                 (condition &&
              //                     !prov.board.lists[widget.listIndex]
              //                         .items[widget.itemIndex].bottomPlaceholder!) ||
              //                 (prov.board.lists[widget.listIndex].items[widget.itemIndex].bottomPlaceholder! &&
              //                     widget.itemIndex ==
              //                         prov.board.lists[widget.listIndex].items.length -
              //                             1))) {

              if (condition && item.bottomPlaceholder!) return b!;

              if (prov.board.dragItemIndex! < widget.itemIndex &&
                  prov.move != 'other') {
                prov.move = "DOWN";
              }
              prov.board.lists[prov.board.dragItemOfListIndex!]
                  .items[prov.board.dragItemIndex!].bottomPlaceholder = false;
              prov.board.lists[prov.board.dragItemOfListIndex!]
                      .items[prov.board.dragItemIndex!].child =
                  prov.board.lists[widget.listIndex]
                      .items[prov.board.dragItemIndex!].prevChild;

              item.bottomPlaceholder = condition;
              if (condition) {
                prov.move = "last";
              }
              item.child = Column(
                children: [
                  !item.bottomPlaceholder!
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(6),
                            color: prov.board.lists[widget.listIndex]
                                    .items[widget.itemIndex].backgroundColor ??
                                Colors.white,
                          ),
                          margin: const EdgeInsets.only(
                              bottom: 15, left: 10, right: 10, top: 15),
                          width: prov.board.lists[widget.listIndex]
                              .items[widget.itemIndex].width,
                          height: item.actualSize!.height,
                        )
                      : Container(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(6),
                      color: prov.board.lists[widget.listIndex]
                              .items[widget.itemIndex].backgroundColor ??
                          Colors.white,
                    ),
                    margin:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    width: prov.board.lists[widget.listIndex]
                        .items[widget.itemIndex].width,
                    child: prov.board.lists[widget.listIndex]
                        .items[widget.itemIndex].prevChild,
                  ),
                  item.bottomPlaceholder!
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(6),
                            color: prov.board.lists[widget.listIndex]
                                    .items[widget.itemIndex].backgroundColor ??
                                Colors.white,
                          ),
                          margin: const EdgeInsets.only(
                              bottom: 15, left: 10, right: 10),
                          width: prov.board.lists[widget.listIndex]
                              .items[widget.itemIndex].width,
                          height: item.actualSize!.height,
                        )
                      : Container(),
                ],
              );

              var temp = prov.board.dragItemIndex;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (!prov.board.lists[prov.board.dragItemOfListIndex!]
                    .items[temp!].context!.mounted) return;
                prov.board.lists[prov.board.dragItemOfListIndex!].items[temp]
                    .setState!();
                prov.board.dragItemIndex = widget.itemIndex;
                prov.board.dragItemOfListIndex = widget.listIndex;
                setState(() {});
              });
            } else if (((prov.draggedItemState!.width * 0.6) +
                        prov.valueNotifier.value.dx >
                    prov.board.lists[widget.listIndex].x!) &&
                ((prov.board.lists[widget.listIndex].x! +
                        prov.board.lists[widget.listIndex].width! >
                    prov.draggedItemState!.width +
                        prov.valueNotifier.value.dx)) &&
                (prov.board.dragItemOfListIndex != widget.listIndex)) {
              // if(widget.itemIndex==2)
              //  log('${prov.valueNotifier.value.dy} >= ${item.y!} && ${item.height! + item.y!} >${prov.valueNotifier.value.dy +(prov.draggedItemState!.height / 2)}');
              if (((prov.valueNotifier.value.dy >= item.y!) &&
                      (item.height! + item.y! >
                          prov.valueNotifier.value.dy +
                              (prov.draggedItemState!.height * 0.6))) ||
                  condition) {
                //     log("RIGHT2");
                prov.move = "other";
                log("RIGHT");
                prov.board.lists[prov.board.dragItemOfListIndex!]
                    .items[prov.board.dragItemIndex!].bottomPlaceholder = false;

                prov.board.lists[prov.board.dragItemOfListIndex!]
                        .items[prov.board.dragItemIndex!].child =
                    prov.board.lists[prov.board.dragItemOfListIndex!]
                        .items[prov.board.dragItemIndex!].prevChild;

                item.bottomPlaceholder = condition;
                 if (condition) {
                prov.move = "last";
              }
                item.child = Column(
                  children: [
                    !item.bottomPlaceholder!
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(6),
                              color: prov
                                      .board
                                      .lists[widget.listIndex]
                                      .items[widget.itemIndex]
                                      .backgroundColor ??
                                  Colors.white,
                            ),
                            margin: const EdgeInsets.only(
                                bottom: 15, left: 10, right: 10, top: 15),
                            width: prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].width,
                            height: item.actualSize!.height,
                          )
                        : Container(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(6),
                        color: prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].backgroundColor ??
                            Colors.white,
                      ),
                      margin: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10),
                      width: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].width,
                      child: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].prevChild,
                    ),
                    item.bottomPlaceholder!
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(6),
                              color: prov
                                      .board
                                      .lists[widget.listIndex]
                                      .items[widget.itemIndex]
                                      .backgroundColor ??
                                  Colors.white,
                            ),
                            margin: const EdgeInsets.only(
                                bottom: 15, left: 10, right: 10),
                            width: prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].width,
                            height: item.actualSize!.height,
                          )
                        : Container(),
                  ],
                );
                
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  prov.board.lists[prov.board.dragItemOfListIndex!]
                      .items[prov.board.dragItemIndex!].setState!();

                  prov.board.dragItemIndex = widget.itemIndex;
                  prov.board.dragItemOfListIndex = widget.listIndex;
                  setState(() {});
                });
              }
            } else if (((prov.draggedItemState!.width) +
                        prov.valueNotifier.value.dx >
                    prov.board.lists[widget.listIndex].x! +
                        prov.board.lists[widget.listIndex].width!) &&
                ((prov.draggedItemState!.width * 0.6) +
                        prov.valueNotifier.value.dx <
                    prov.board.lists[widget.listIndex].x! +
                        prov.board.lists[widget.listIndex].width!) &&
                (prov.board.dragItemOfListIndex != widget.listIndex)) {
              // log("RIGHT1");
              // if(widget.itemIndex==2)
              //  log('${prov.valueNotifier.value.dy} >= ${item.y!} && ${item.height! + item.y!} >${prov.valueNotifier.value.dy +(prov.draggedItemState!.height / 2)}');
              if (((prov.valueNotifier.value.dy >= item.y!) &&
                      (item.height! + item.y! >
                          prov.valueNotifier.value.dy +
                              (prov.draggedItemState!.height / 2))) ||
                  condition) {
                log("LEFT");
                prov.move = "other";

                prov.board.lists[prov.board.dragItemOfListIndex!]
                    .items[prov.board.dragItemIndex!].bottomPlaceholder = false;

                prov.board.lists[prov.board.dragItemOfListIndex!]
                        .items[prov.board.dragItemIndex!].child =
                    prov.board.lists[prov.board.dragItemOfListIndex!]
                        .items[prov.board.dragItemIndex!].prevChild;

                item.bottomPlaceholder = condition;
                 if (condition) {
                prov.move = "last";
              }
                item.child = Column(
                  children: [
                    !item.bottomPlaceholder!
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(6),
                              color: prov
                                      .board
                                      .lists[widget.listIndex]
                                      .items[widget.itemIndex]
                                      .backgroundColor ??
                                  Colors.white,
                            ),
                            margin: const EdgeInsets.only(
                                bottom: 15, left: 10, right: 10, top: 15),
                            width: prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].width,
                            height: item.actualSize!.height,
                          )
                        : Container(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(6),
                        color: prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].backgroundColor ??
                            Colors.white,
                      ),
                      margin: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10),
                      width: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].width,
                      child: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].prevChild,
                    ),
                    item.bottomPlaceholder!
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(6),
                              color: prov
                                      .board
                                      .lists[widget.listIndex]
                                      .items[widget.itemIndex]
                                      .backgroundColor ??
                                  Colors.white,
                            ),
                            margin: const EdgeInsets.only(
                                bottom: 15, left: 10, right: 10),
                            width: prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].width,
                            height: item.actualSize!.height,
                          )
                        : Container(),
                  ],
                );

                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  prov.board.lists[prov.board.dragItemOfListIndex!]
                      .items[prov.board.dragItemIndex!].setState!();

                  prov.board.dragItemIndex = widget.itemIndex;
                  prov.board.dragItemOfListIndex = widget.listIndex;
                  setState(() {});
                });
              }
            }
          }
          return b!;
        },
        child: GestureDetector(
          onLongPress: () {
            var box = context.findRenderObject() as RenderBox;
            location = box.localToGlobal(Offset.zero);
            prov.board.lists[widget.listIndex].items[widget.itemIndex].x =
                location.dx - prov.board.displacementX!;
            prov.board.lists[widget.listIndex].items[widget.itemIndex].y =
                location.dy - prov.board.displacementY!;
            prov.board.lists[widget.listIndex].items[widget.itemIndex].width =
                box.size.width;
            prov.board.lists[widget.listIndex].items[widget.itemIndex].height =
                box.size.height;
            prov.updateValue(
                dx: location.dx - prov.board.displacementX!,
                dy: location.dy - prov.board.displacementY!);
            prov.board.dragItemIndex = widget.itemIndex;
            prov.board.dragItemOfListIndex = widget.listIndex;
            prov.board.isElementDragged = true;
            prov.draggedItemState = DraggedItemState(
                child: Container(
                  color: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].backgroundColor ??
                      Colors.white,
                  width: box.size.width - 20,
                  child: prov.board.lists[widget.listIndex]
                      .items[widget.itemIndex].child,
                ),
                listIndex: widget.listIndex,
                itemIndex: widget.itemIndex,
                height: box.size.height,
                width: box.size.width,
                x: location.dx,
                y: location.dy);
            prov.draggedItemState!.setState =
                prov.board.lists[widget.listIndex].setState;
            // log("${widget.listIndex} ${widget.itemIndex}");
            setState(() {});
            // prov.notifyListeners();
          },
          child: prov.board.isElementDragged &&
                  prov.board.dragItemIndex == widget.itemIndex &&
                  prov.draggedItemState!.itemIndex == widget.itemIndex &&
                  prov.draggedItemState!.listIndex == widget.listIndex &&
                  prov.board.dragItemOfListIndex! == widget.listIndex
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(6),
                    color: prov.board.lists[widget.listIndex]
                            .items[widget.itemIndex].backgroundColor ??
                        Colors.white,
                  ),
                  margin: const EdgeInsets.only(
                      bottom: 15, left: 10, right: 10, top: 15),
                  width: prov.board.lists[widget.listIndex]
                      .items[widget.itemIndex].width,
                  height: prov.board.lists[widget.listIndex]
                      .items[widget.itemIndex].height,
                  // width: prov.board.lists[widget.listIndex]
                  //     .items[widget.itemIndex].width,
                  // height: prov.board.lists[widget.listIndex]
                  //     .items[widget.itemIndex].height,
                )
              : prov.board.isElementDragged &&
                      prov.draggedItemState!.itemIndex == widget.itemIndex &&
                      prov.draggedItemState!.listIndex == widget.listIndex
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(6),
                        color: prov.board.lists[widget.listIndex]
                                .items[widget.itemIndex].backgroundColor ??
                            Colors.white,
                      ),
                      // margin: const EdgeInsets.only(
                      //     bottom: 15, left: 10, right: 10),
                      width: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].width,
                    )
                  : Container(
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.grey.shade100),
                      //   borderRadius: BorderRadius.circular(6),
                      //   color: prov.board.lists[widget.listIndex]
                      //           .items[widget.itemIndex].backgroundColor ??
                      //       Colors.white,
                      // ),
                      // margin: const EdgeInsets.only(
                      //     bottom: 15, left: 10, right: 10),
                      width: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].width,
                      child: prov.board.lists[widget.listIndex]
                          .items[widget.itemIndex].child,
                    ),
        ));
  }
}

/*                  MOVE RIGHT SIDE

          if ((((prov.draggedItemState!.height / 2) +
                          prov.valueNotifier.value.dy <
                      nextList.items[widget.itemIndex].y!) &&
                  ((prov.draggedItemState!.height) +
                          prov.valueNotifier.value.dy >
                      nextList.items[widget.itemIndex].y! ))
                           &&
              ((prov.draggedItemState!.width / 2) +
                      prov.valueNotifier.value.dx >
                  prov.board.lists[widget.listIndex].x!)


                      MOVE LEFT SIDE


                  (prov.board.dragItemOfListIndex! - 1 ==
                    widget.listIndex &&
                ((prov.draggedItemState!.width * 0.6) +
                        prov.valueNotifier.value.dx <
                    prov.board.lists[widget.listIndex].x! +
                        prov.board.lists[widget.listIndex].width!) &&
                (prov.board.dragItemOfListIndex != widget.listIndex))

  */




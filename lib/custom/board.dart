import 'dart:developer' as dev;
import 'dart:math';
import 'package:boardview/custom/board_list.dart';
import 'package:boardview/models/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Provider/provider_list.dart';
import '../models/item_state.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard(
    this.list, {
    this.backgroundColor = Colors.white,
    this.cardPlaceHolderColor,
    this.listPlaceHolderColor,
    this.boardDecoration,
    this.cardTransitionBuilder,
    this.listTransitionBuilder,
    this.cardTransitionDuration = const Duration(milliseconds: 150),
    this.listTransitionDuration = const Duration(milliseconds: 150),
    this.listDecoration,
    this.textStyle,
    this.onItemTap,
    this.displacementX = 0.0,
    this.displacementY = 0.0,
    this.onItemReorder,
    this.onListReorder,
    this.onListRename,
    this.onNewCardInsert,
    this.onItemLongPress,
    this.onListTap,
    this.onListLongPress,
    super.key,
  });
  final List<BoardListsData> list;
  final Color backgroundColor;
  final Color? cardPlaceHolderColor;
  final Color? listPlaceHolderColor;
  final TextStyle? textStyle;
  final Decoration? listDecoration;
  final Decoration? boardDecoration;
  final void Function(int? cardIndex, int? listIndex)? onItemTap;
  final void Function(int? cardIndex, int? listIndex)? onItemLongPress;
  final void Function(int? listIndex)? onListTap;
  final void Function(int? listIndex)? onListLongPress;
  final void Function(int? oldCardIndex, int? newCardIndex, int? oldListIndex,
      int? newListIndex)? onItemReorder;
  final void Function(int? oldListIndex, int? newListIndex)? onListReorder;
  final void Function(String? oldName, String? newName)? onListRename;
  final void Function(String? cardIndex, String? listIndex, String? text)?
      onNewCardInsert;
  final Widget Function(Widget child, Animation<double> animation)?
      cardTransitionBuilder;
  final Widget Function(Widget child, Animation<double> animation)?
      listTransitionBuilder;
  final double displacementX;
  final double displacementY;
  final Duration cardTransitionDuration;
  final Duration listTransitionDuration;

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Board(widget.list,
          displacementX: widget.displacementX,
          displacementY: widget.displacementY,
          backgroundColor: widget.backgroundColor,
          boardDecoration: widget.boardDecoration,
          cardPlaceHolderColor: widget.cardPlaceHolderColor,
          listPlaceHolderColor: widget.listPlaceHolderColor,
          listDecoration: widget.listDecoration,
          textStyle: widget.textStyle,
          onItemTap: widget.onItemTap,
          onItemLongPress: widget.onItemLongPress,
          onListTap: widget.onListTap,
          onListLongPress: widget.onListLongPress,
          onItemReorder: widget.onItemReorder,
          onListReorder: widget.onListReorder,
          onListRename: widget.onListRename,
          onNewCardInsert: widget.onNewCardInsert,
          cardTransitionBuilder: widget.cardTransitionBuilder,
          listTransitionBuilder: widget.listTransitionBuilder,
          cardTransitionDuration: widget.cardTransitionDuration,
          listTransitionDuration: widget.listTransitionDuration),
    ));
  }
}

class Board extends ConsumerStatefulWidget {
  const Board(
    this.list, {
    this.backgroundColor = Colors.white,
    this.cardPlaceHolderColor,
    this.listPlaceHolderColor,
    this.boardDecoration,
    this.cardTransitionBuilder,
    this.listTransitionBuilder,
    this.cardTransitionDuration = const Duration(milliseconds: 150),
    this.listTransitionDuration = const Duration(milliseconds: 150),
    this.listDecoration,
    this.textStyle,
    this.onItemTap,
    this.displacementX = 0.0,
    this.displacementY = 0.0,
    this.onItemReorder,
    this.onListReorder,
    this.onListRename,
    this.onNewCardInsert,
    this.onItemLongPress,
    this.onListTap,
    this.onListLongPress,
    super.key,
  });
  final List<BoardListsData> list;
  final Color backgroundColor;
  final Color? cardPlaceHolderColor;
  final Color? listPlaceHolderColor;
  final TextStyle? textStyle;
  final Decoration? listDecoration;
  final Decoration? boardDecoration;
  final void Function(int? cardIndex, int? listIndex)? onItemTap;
  final void Function(int? cardIndex, int? listIndex)? onItemLongPress;
  final void Function(int? listIndex)? onListTap;
  final void Function(int? listIndex)? onListLongPress;
  final void Function(int? oldCardIndex, int? newCardIndex, int? oldListIndex,
      int? newListIndex)? onItemReorder;
  final void Function(int? oldListIndex, int? newListIndex)? onListReorder;
  final void Function(String? oldName, String? newName)? onListRename;
  final void Function(String? cardIndex, String? listIndex, String? text)?
      onNewCardInsert;
  final Widget Function(Widget child, Animation<double> animation)?
      cardTransitionBuilder;
  final Widget Function(Widget child, Animation<double> animation)?
      listTransitionBuilder;
  final double displacementX;
  final double displacementY;
  final Duration cardTransitionDuration;
  final Duration listTransitionDuration;

  @override
  ConsumerState<Board> createState() => _BoardState();
}

class _BoardState extends ConsumerState<Board> {
  bool scrolling = false;
  bool scrollingUp = false;
  bool scrollingDown = false;
  bool scrollingLeft = false;
  bool scrollingRight = false;
  @override
  void initState() {
    var prov = ref.read(ProviderList.reorderProvider);
    prov.initializeBoard(
        data: widget.list,
        displacementX: widget.displacementX,
        displacementY: widget.displacementY,
        backgroundColor: widget.backgroundColor,
        boardDecoration: widget.boardDecoration,
        cardPlaceHolderColor: widget.cardPlaceHolderColor,
        listPlaceHolderColor: widget.listPlaceHolderColor,
        listDecoration: widget.listDecoration,
        textStyle: widget.textStyle,
        onItemTap: widget.onItemTap,
        onItemLongPress: widget.onItemLongPress,
        onListTap: widget.onListTap,
        onListLongPress: widget.onListLongPress,
        onItemReorder: widget.onItemReorder,
        onListReorder: widget.onListReorder,
        onListRename: widget.onListRename,
        onNewCardInsert: widget.onNewCardInsert,
        cardTransitionBuilder: widget.cardTransitionBuilder,
        listTransitionBuilder: widget.listTransitionBuilder,
        cardTransitionDuration: widget.cardTransitionDuration,
        listTransitionDuration: widget.listTransitionDuration);

    for (var element in prov.board.lists) {
      element.scrollController.addListener(() {
        if (scrolling) {
          ListItem? closest;
          double closestDistance = double.infinity;
          // dev.log("CALLED");
          if (scrollingDown) {
            prov.valueNotifier.value = Offset(prov.valueNotifier.value.dx,
                prov.valueNotifier.value.dy + 0.00001);
            return;
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
              element.x = of.dx - prov.board.displacementX!;
              element.y = of.dy - widget.displacementY;
            }
            // dev.log("MOVE DOWN SCROLL");
            //   moveDown();
          } else {
            prov.valueNotifier.value = Offset(prov.valueNotifier.value.dx,
                prov.valueNotifier.value.dy + 0.00001);
            return;
            for (var i = 0;
                i <
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
              element.x = of.dx - prov.board.displacementX!;
              element.y = of.dy - widget.displacementY;
            }
            //  dev.log("MOVE UP SCROLL");
            moveUp();
          }
        }
      });
    }
    prov.board.controller.addListener(() {
      if (scrolling) {
        // return;
        // if (scrollingLeft && prov.board.isElementDragged) {
        //   moveLeft();
        // } else if (scrollingRight && prov.board.isElementDragged) {
        //   moveRight();
        // } else
        if (scrollingLeft && prov.board.isListDragged) {
          for (var element in prov.board.lists) {
            if (element.context == null) break;
            var of = (element.context!.findRenderObject() as RenderBox)
                .localToGlobal(Offset.zero);
            element.x = of.dx - prov.board.displacementX! - 10;
            element.width = element.context!.size!.width - 30;
            element.y = of.dy - widget.displacementY + 24;
          }
          moveListLeft();
        } else if (scrollingRight && prov.board.isListDragged) {
          for (var element in prov.board.lists) {
            if (element.context == null) break;
            var of = (element.context!.findRenderObject() as RenderBox)
                .localToGlobal(Offset.zero);
            element.x = of.dx - prov.board.displacementX! - 10;
            element.width = element.context!.size!.width - 30;
            element.y = of.dy - widget.displacementY + 24;
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
        prov.board.lists[prov.board.dragItemOfListIndex!].scrollController;
    if (controller.offset < controller.position.maxScrollExtent &&
        prov.valueNotifier.value.dy >
            controller.position.viewportDimension - 100) {
      scrolling = true;
      scrollingDown = true;
      await controller.animateTo(controller.offset + 45,
          duration: const Duration(milliseconds: 250), curve: Curves.linear);
      scrolling = false;
      scrollingDown = false;

      maybeScroll();
    } else if (controller.offset > 0 && prov.valueNotifier.value.dy < 100) {
      scrolling = true;
      scrollingUp = true;
      await controller.animateTo(controller.offset - 45,
          duration: Duration(
              milliseconds: prov.valueNotifier.value.dy < 50 ? 100 : 250),
          curve: Curves.linear);
      scrolling = false;
      scrollingUp = false;
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

  void moveDown() {
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
        .items[prov.board.dragItemIndex! + 1].y!;

    if (prov.valueNotifier.value.dy + 50 > position &&
        prov.valueNotifier.value.dy + 50 < position + 130) {
      //dev.log("DOWN ${prov.board.dragItemOfListIndex}");

      prov.board.lists[prov.board.dragItemOfListIndex!].items.insert(
          prov.board.dragItemIndex! + 1,
          prov.board.lists[prov.board.dragItemOfListIndex!].items
              .removeAt(prov.board.dragItemIndex!));
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

    var prevItem = prov.board.lists[prov.board.dragItemOfListIndex!]
        .items[prov.board.dragItemIndex! - 1];
    var box = (prevItem.context?.findRenderObject() as RenderBox)
        .localToGlobal(Offset.zero);
    prevItem.x = box.dx - prov.board.displacementX!;
    prevItem.y = box.dy - prov.board.displacementY!;
    // dev.log(
    //     "UP INDEX = ${prov.draggedItemState!.itemIndex} ${prov.board.lists[prov.draggedItemState!.listIndex ?? 1].items[prov.draggedItemState!.itemIndex! - 1].y}");
    if (prov.valueNotifier.value.dy < prevItem.y! + (prevItem.height! / 2) &&
        prov.valueNotifier.value.dy + prov.draggedItemState!.height <
            prov.board.lists[prov.board.dragItemOfListIndex!]
                    .items[prov.board.dragItemIndex!].y! +
                prov.board.lists[prov.board.dragItemOfListIndex!]
                    .items[prov.board.dragItemIndex!].height!) {
      // newAdded = true;
      prov.board.lists[prov.board.dragItemOfListIndex!].items.insert(
        prov.board.dragItemIndex! - 1,
        prov.board.lists[prov.board.dragItemOfListIndex!].items
            .removeAt(prov.board.dragItemIndex!),
      );
      // dev.log(
      // "UP REMOVED=${prov.board.dragItemIndex!} INSERT=${prov.board.dragItemIndex! - 1}");
      prov.board.dragItemIndex = prov.board.dragItemIndex! - 1;
      // dev.log("UP 1");
      prov.board.lists[prov.board.dragItemOfListIndex!].setState!();
    }
  }

  void moveRight() {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.draggedItemState!.listIndex == prov.board.lists.length - 1) {
      prov.movingItemRight = false;
      return;
    }

    int? closest;
    double closestDistance = double.infinity;

    var nextList = prov.board.lists[prov.board.dragItemOfListIndex! + 1];
    var box = (nextList.context?.findRenderObject() as RenderBox)
        .localToGlobal(Offset.zero);
    nextList.x = box.dx - prov.board.displacementX! - 10;
    nextList.y = box.dy - prov.board.displacementY! + 24;
    if (prov.valueNotifier.value.dx +
            // prov.board.controller.offset +
            (prov.board.lists[prov.board.dragItemOfListIndex!].width! / 2) <
        nextList.x!) {
      // dev.log(
      //     "RIGHT RETURN ${prov.valueNotifier.value.dx + (prov.board.lists[prov.board.dragItemOfListIndex!].width! / 2)} ${prov.board.lists[prov.board.dragItemOfListIndex! + 1].x!}");
      return;
    }
    // dev.log("RIGHT=${nextList.items.length}");
    // prov.movingItemRight = true;
    // nextList.setState!();
    // return;
    for (var i = 0; i < nextList.items.length; i++) {
      var element = nextList.items[i];

      double val = prov.valueNotifier.value.dy;
      // if (element.y < val) continue;
      if (element.context == null) continue;
      if (!element.context!.mounted) continue;
      var of = (element.context!.findRenderObject() as RenderBox)
          .localToGlobal(Offset.zero);
      element.x = of.dx - prov.board.displacementX!;
      element.y = of.dy - prov.board.displacementY!;
      // dev.log("$i= ${element.y.toString()}");
      if (element.y == null || element.y! < 0 || element.y!.isNaN) continue;

      if (closestDistance == double.infinity ||
          closestDistance > (val - element.y!).abs()) {
        closest = prov.valueNotifier.value.dy > element.y!
            ? element.index + 1
            : element.index;
        closestDistance = (val - element.y!).abs();
      } else {
        break;
      }
    }
    closest ??= 0;
    nextList.items.insert(
        closest,
        prov.board.lists[prov.board.dragItemOfListIndex!].items
            .removeAt(prov.board.dragItemIndex!));
    dev.log("RIGHT CLOSEST = $closest");
    prov.draggedItemState!.listIndex = prov.board.dragItemOfListIndex! + 1;
    prov.board.dragItemOfListIndex = prov.draggedItemState!.listIndex!;
    prov.board.dragItemIndex = closest;
    prov.draggedItemState!.itemIndex = closest;
    prov.board.lists[prov.draggedItemState!.listIndex! - 1].setState!();
    prov.board.lists[prov.draggedItemState!.listIndex!].setState!();
  }

  void moveLeft() {
    var prov = ref.read(ProviderList.reorderProvider);
    if (prov.board.dragItemOfListIndex == 0) {
      return;
    }
    var prevList = prov.board.lists[prov.board.dragItemOfListIndex! - 1];
    var box = (prevList.context?.findRenderObject() as RenderBox)
        .localToGlobal(Offset.zero);
    prevList.x = box.dx - prov.board.displacementX!;
    prevList.y = box.dy - prov.board.displacementY!;
    int? closest;
    prov.movingItemRight = false;
    double closestDistance = double.infinity;
    if (prov.valueNotifier.value.dx > prevList.x! + (prevList.width! / 2)) {
      // dev.log(
      //     "${prov.valueNotifier.value.dx}==${prevList.x! + (prevList.width! / 2)}");
      return;
    }
    // dev.log(
    //     "${prov.valueNotifier.value.dx}==${prevList.x! + (prevList.width! / 2)}");
    for (var i = 0; i < prevList.items.length; i++) {
      var element = prevList.items[i];
      double val = prov.valueNotifier.value.dy;
      // if (element.y < val) continue;
      if (element.context == null) continue;
      //log("ELEMENT Y = ${element.itemIndex}");
      var of = (element.context!.findRenderObject() as RenderBox)
          .localToGlobal(Offset.zero);
      element.x = of.dx - prov.board.displacementX!;
      element.y = of.dy - prov.board.displacementY!;
      if (element.y == null || element.y! < 0 || element.y!.isNaN) continue;
      if (closestDistance == double.infinity ||
          closestDistance > (val - element.y!).abs()) {
        closest = prov.valueNotifier.value.dy > element.y!
            ? element.index + 1
            : element.index;
        closestDistance = (val - element.y!).abs();
      }
    }
    // if (prov.valueNotifier.value.dx >
    //     prov.board.lists[prov.draggedItemState!.listIndex + 1].x! +
    //         (prov.board.lists[prov.draggedItemState!.listIndex + 1].width! /
    //             2)) {
    // dev.log("LEFT=$closest");
    closest ??= 0;
    //if (closest == prevList.items.length) closest = closest - 1;
    prevList.items.insert(
        closest,
        prov.board.lists[prov.board.dragItemOfListIndex!].items
            .removeAt(prov.board.dragItemIndex!));
    // dev.log("LEFT REMOVED=${prov.board.dragItemIndex!} INSERT=${closest}");
    prov.draggedItemState!.listIndex = prov.board.dragItemOfListIndex! - 1;
    prov.board.dragItemOfListIndex = prov.draggedItemState!.listIndex;
    prov.board.dragItemIndex = closest;
    prov.draggedItemState!.itemIndex = closest;

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
    // dev.log("LIST RIGHT");
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var box = context.findRenderObject() as RenderBox;
      prov.board.displacementX =
          box.localToGlobal(Offset.zero).dx - 10; //- margin
      prov.board.displacementY =
          box.localToGlobal(Offset.zero).dy + 24; // statusbar
    });
    return Listener(
      onPointerUp: (event) {
        if (prov.board.isElementDragged || prov.board.isListDragged) {
          if (prov.board.isElementDragged) {
            setState(() {
              prov.board.lists[prov.board.dragItemOfListIndex!]
                      .items[prov.board.dragItemIndex!].child =
                  prov.board.lists[prov.board.dragItemOfListIndex!]
                      .items[prov.board.dragItemIndex!].prevChild;
              //dev.log("MOVE=${prov.move}");
              prov.board.lists[prov.board.dragItemOfListIndex!].items.insert(
                  prov.move == "DOWN"
                      ? prov.board.dragItemIndex! - 1 < 0
                          ? prov.board.dragItemIndex!
                          : prov.board.dragItemIndex! - 1
                      : prov.move == "last"
                      ? prov.board.dragItemIndex! + 1 > prov.board.lists[prov.board.dragItemOfListIndex!].items.length-1
                          ?  prov.board.lists[prov.board.dragItemOfListIndex!].items.length-1
                          : prov.board.dragItemIndex! + 1
                      :prov.board.dragItemIndex!,
                  prov.board.lists[prov.draggedItemState!.listIndex!].items
                      .removeAt(prov.draggedItemState!.itemIndex!));
              // prov.board.lists[prov.board.dragItemOfListIndex!].setState! ();
            });
          }

          prov.setcanDrag(value: false, listIndex: 0, itemIndex: 0);
          setState(() {});
        }
      },
      onPointerMove: (event) {
        if (prov.board.isElementDragged) {
          if (event.delta.dy > 0) {
            //   moveDown();
          } else {
            //  moveUp();
          }
          if (event.delta.dx > 0) {
            boardScroll();
            //  moveRight();
          } else {
            boardScroll();
            // moveLeft();
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
      child: GestureDetector(
        onTap: () {
          if (prov.board.newCardFocused == true) {
            prov.board.lists[prov.board.newCardListIndex!]
                .items[prov.board.newCardIndex!].child = Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(prov.board.newCardTextController.text,
                  style: widget.textStyle),
            );
            prov.board.newCardFocused = false;
            prov.board.lists[prov.board.newCardListIndex!]
                .items[prov.board.newCardIndex!].isNew = false;
            prov.board.lists[prov.board.newCardListIndex!]
                .items[prov.board.newCardIndex!].setState!();
            prov.board.newCardIndex = null;
            prov.board.newCardListIndex = null;
            // dev.log("TAPPED");
          }
        },
        child: Scaffold(
          body: Container(
            decoration: widget.boardDecoration ??
                BoxDecoration(color: widget.backgroundColor),
            margin: const EdgeInsets.only(top: 24),
            child: Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        //width: 200,
                        height: 1200,
                        child: SingleChildScrollView(
                          controller: prov.board.controller,
                          scrollDirection: Axis.horizontal,
                          child: Transform(
                            alignment: Alignment.topLeft,
                            // scaleX: 0.45,
                            transform: Matrix4(
                                1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
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
                              opacity: 0.7,
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

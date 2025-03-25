import 'dart:developer';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/draggable/draggable_state.dart';
import '../models/board_list.dart';
import '../models/item_state.dart';
import 'provider_list.dart';

class ListItemProvider extends ChangeNotifier {
  ListItemProvider(ChangeNotifierProviderRef<ListItemProvider> this.ref);
  Ref ref;
  TextEditingController newCardTextController = TextEditingController();

  void calculateCardPositionSize(
      {required int listIndex,
      required int itemIndex,
      required BuildContext context,
      required VoidCallback setsate}) {
    var prov = ref.read(ProviderList.boardProvider);
    if (!context.mounted) return;
    prov.board.lists[listIndex].items[itemIndex].context = context;
    var box = context.findRenderObject() as RenderBox;
    var location = box.localToGlobal(Offset.zero);
    prov.board.lists[listIndex].items[itemIndex].setState = setsate;
    prov.board.lists[listIndex].items[itemIndex].x =
        location.dx - prov.board.displacementX!;
    prov.board.lists[listIndex].items[itemIndex].y =
        location.dy - prov.board.displacementY!;
    prov.board.lists[listIndex].items[itemIndex].actualSize ??= box.size;
    prov.board.lists[listIndex].items[itemIndex].width = box.size.width;
    prov.board.lists[listIndex].items[itemIndex].height = box.size.height;
  }

  void resetCardWidget() {
    var prov = ref.read(ProviderList.boardProvider);
    prov.board.lists[prov.board.dragItemOfListIndex!]
        .items[prov.board.dragItemIndex!].placeHolderAt = PlaceHolderAt.none;
    prov.board.lists[prov.board.dragItemOfListIndex!]
        .items[prov.board.dragItemIndex!].placeHolderAt = PlaceHolderAt.none;
    prov.board.lists[prov.board.dragItemOfListIndex!]
            .items[prov.board.dragItemIndex!].child =
        prov.board.lists[prov.board.dragItemOfListIndex!]
            .items[prov.board.dragItemIndex!].prevChild;
  }

  bool calculateSizePosition({
    required int listIndex,
    required int itemIndex,
  }) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];
    var list = prov.board.lists[listIndex];
    if (item.context == null ||
        list.context == null ||
        !item.context!.mounted) {
      return true;
    }
    var box = item.context!.findRenderObject();
    var listBox = list.context!.findRenderObject();
    if (box == null || listBox == null) return true;

    box = box as RenderBox;
    listBox = listBox as RenderBox;
    var location = box.localToGlobal(Offset.zero);
    item.x = location.dx - prov.board.displacementX!;
    item.y = location.dy - prov.board.displacementY!;

    item.actualSize ??= box.size;

    // log("EXECUTED");

    item.width = box.size.width;
    item.height = box.size.height;
    list.x = listBox.localToGlobal(Offset.zero).dx - prov.board.displacementX!;
    list.y = listBox.localToGlobal(Offset.zero).dy - prov.board.displacementY!;
    return false;
  }

  void addPlaceHolder({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];
    item.child = Column(
      children: [
        // AnimatedOpacity(opacity: opacity, duration: duration)
        item.placeHolderAt != PlaceHolderAt.bottom
            ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 3000),
                curve: Curves.ease,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.grey.shade200),
                  //   borderRadius: BorderRadius.circular(4),
                  //   color: item.backgroundColor ?? Colors.white,
                  // ),
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  width: prov.draggedItemState!.width,
                  height: prov.draggedItemState!.height,
                  child: DottedBorder(
                    child: const Center(
                        child: Text(
                      "Drop your task here ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              )
            : Container(),
        // Container(
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(4),
        //     color: item.backgroundColor ?? Colors.white,
        //   ),
        //   width: item.actualSize!.width,
        //   child: item.prevChild,
        // ),
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          tween: Tween<double>(begin: item.actualSize!.height, end: 0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(
                  0,
                  item.placeHolderAt == PlaceHolderAt.bottom
                      ? value
                      : (-value)),
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: item.backgroundColor ?? Colors.white,
            ),
            width: item.actualSize!.width,
            child: item.prevChild,
          ),
        ),
        item.placeHolderAt == PlaceHolderAt.bottom
            ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 3000),
                curve: Curves.ease,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.grey.shade200),
                  //   borderRadius: BorderRadius.circular(4),
                  //   color: item.backgroundColor ?? Colors.white,
                  // ),
                  margin: const EdgeInsets.only(top: 10),
                  width: prov.draggedItemState!.width,
                  height: prov.draggedItemState!.height,
                  child: DottedBorder(
                    child: const Center(
                        child: Text(
                      "Drop your task here ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  bool isPrevSystemCard({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];
    var isItemHidden = itemIndex - 1 >= 0 &&
        prov.draggedItemState!.itemIndex == itemIndex - 1 &&
        prov.draggedItemState!.listIndex == listIndex;
    if (prov.board.lists[prov.board.dragItemOfListIndex!]
            .items[prov.board.dragItemIndex!].addedBySystem ==
        true) {
      prov.board.lists[prov.board.dragItemOfListIndex!].items.removeAt(0);
      log("ITEM REMOVED");

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        prov.board.lists[prov.board.dragItemOfListIndex!].setState!();
        if (isItemHidden) {
          //  print("ITEM HIDDEN");
          prov.move = "DOWN";
        }
        prov.board.dragItemIndex = itemIndex;
        prov.board.dragItemOfListIndex = listIndex;

        //  log("UPDATED | ITEM= ${prov.board.dragItemIndex} | LIST= $listIndex");
        item.setState!();
      });

      return true;
    }
    return false;
  }

  void checkForYAxisMovement({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];

    bool willPlaceHolderAtBottom =
        _bottomPlaceHolderPossibility(listIndex, itemIndex);
    // willPlaceHolderAtBottom = ((itemIndex ==
    //         prov.board.lists[listIndex].items.length - 1) &&
    //     ((prov.draggedItemState!.height * 0.6) + prov.valueNotifier.value.dy >
    //         item.y! + item.height!) &&
    //     item.placeHolderAt != PlaceHolderAt.bottom &&
    //     prov.board.lists[listIndex].items[itemIndex].addedBySystem != true);

    // willPlaceHolderAtTop =
    //     ((prov.valueNotifier.value.dy < item.y! + (item.height! * 0.5)) &&
    //             (prov.draggedItemState!.height + prov.valueNotifier.value.dy >
    //                 item.y! + (item.height! * 0.5))) &&
    //         prov.board.lists[listIndex].items[itemIndex].addedBySystem != true;

    // print(willPlaceHolderAtTop);
    // if (((willPlaceHolderAtTop || willPlaceHolderAtBottom) &&
    //         prov.board.dragItemOfListIndex! == listIndex) &&
    //     (prov.board.dragItemIndex != itemIndex ||
    //         (willPlaceHolderAtBottom &&
    //             item.placeHolderAt != PlaceHolderAt.bottom) ||
    //         (item.placeHolderAt == PlaceHolderAt.bottom &&
    //             (itemIndex == prov.board.lists[listIndex].items.length - 1))))
    if (getYAxisCondition(listIndex: listIndex, itemIndex: itemIndex)) {
      // log("UP/DOWNN");
      // print("BOTTOM PLACEHOLDER => ${willPlaceHolderAtBottom}");
      if (willPlaceHolderAtBottom &&
          item.placeHolderAt == PlaceHolderAt.bottom) {
        return;
      }

      if (prov.board.dragItemIndex! < itemIndex && prov.move != 'other') {
        prov.move = "DOWN";
      }

      resetCardWidget();

      item.placeHolderAt =
          willPlaceHolderAtBottom ? PlaceHolderAt.bottom : PlaceHolderAt.top;

      if (willPlaceHolderAtBottom) {
        prov.move = "LAST";
      }
      var isItemHidden = itemIndex - 1 >= 0 &&
          prov.draggedItemState!.itemIndex == itemIndex - 1 &&
          prov.draggedItemState!.listIndex == listIndex;

      if ((item.addedBySystem == null || !item.addedBySystem!)) {
        addPlaceHolder(listIndex: listIndex, itemIndex: itemIndex);
        // log("${item.placeHolderAt.name}=>${item.height}");
      }
      if (isPrevSystemCard(listIndex: listIndex, itemIndex: itemIndex)) return;

      var temp = prov.board.dragItemIndex;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        //     log("PREVIOUS |${prov.board.dragItemOfListIndex}| LIST= ${prov.board.dragItemIndex}");

        if (!prov.board.lists[prov.board.dragItemOfListIndex!].items[temp!]
            .context!.mounted) return;

        if (isItemHidden) {
          prov.move = "DOWN";
        }
        if (itemIndex != prov.board.dragItemIndex &&
            prov.board.dragItemOfListIndex != listIndex) {
          prov.board.lists[prov.board.dragItemOfListIndex!].items[temp]
              .placeHolderAt = PlaceHolderAt.none;
        }

        prov.board.dragItemIndex = itemIndex;
        prov.board.dragItemOfListIndex = listIndex;
        prov.board.lists[prov.board.dragItemOfListIndex!].items[temp]
            .setState!();
        //  log("UP/DOWN $listIndex $itemIndex");
        item.setState!();
      });
    }
  }

  bool isLastItemDragged({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];
    if (prov.draggedItemState!.itemIndex == itemIndex &&
        prov.draggedItemState!.listIndex == listIndex &&
        prov.board.lists[listIndex].items.length - 1 == itemIndex &&
        prov.board.dragItemIndex == itemIndex &&
        prov.board.dragItemOfListIndex == listIndex) {
      return true;
    }

    if ((prov.draggedItemState!.itemIndex == itemIndex &&
        prov.draggedItemState!.listIndex == listIndex &&
        prov.board.dragItemOfListIndex == listIndex &&
        prov.board.lists[listIndex].items.length - 1 == itemIndex &&
        ((prov.draggedItemState!.height * 0.6) + prov.valueNotifier.value.dy >
            item.y! + item.height!))) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        // log("PREVIOUS |${prov.board.dragItemOfListIndex}| LIST= ${prov.board.dragItemIndex}");

        // if (isItemHidden) {
        //   prov.move = "DOWN";
        // }
        prov.board.lists[prov.board.dragItemOfListIndex!]
                .items[prov.board.dragItemIndex!].child =
            prov.board.lists[prov.board.dragItemOfListIndex!]
                .items[prov.board.dragItemIndex!].prevChild;
        prov.board.lists[prov.board.dragItemOfListIndex!]
            .items[prov.board.dragItemIndex!].setState!();
        prov.board.dragItemIndex = itemIndex;
        prov.board.dragItemOfListIndex = listIndex;

        // log("UP/DOWN $listIndex $itemIndex");
        item.setState!();
      });
      return true;
    }
    return false;
  }

  bool _topPlaceHolderPossibility(int listIndex, int itemIndex) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];

    var willPlaceHolderAtTop = item.placeHolderAt == PlaceHolderAt.bottom
        ? (prov.valueNotifier.value.dy <
            item.y! + (item.actualSize!.height * 0.65))
        : ((prov.valueNotifier.value.dy <=
                item.y! + (item.actualSize!.height * 0.65)) &&
            (prov.draggedItemState!.height + prov.valueNotifier.value.dy >
                item.y! + (item.height!)));

    bool x = (item.placeHolderAt == PlaceHolderAt.bottom
        ? item.height != item.actualSize!.height
        : true);
    // if (item.placeHolderAt == PlaceHolderAt.bottom) {
    //   print("BOTTOM TRUE");
    // }

    return willPlaceHolderAtTop &&
        prov.delta.dy < 0 &&
        item.placeHolderAt != PlaceHolderAt.top &&
        x &&
        prov.board.dragItemOfListIndex! == listIndex &&
        item.addedBySystem != true;
  }

  bool _bottomPlaceHolderPossibility(int listIndex, int itemIndex) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];
    var willPlaceHolderAtBottom = item.placeHolderAt == PlaceHolderAt.top
        ? (prov.draggedItemState!.height + prov.valueNotifier.value.dy >=
            item.y! + (item.height! * 0.8))
        : ((prov.draggedItemState!.height + prov.valueNotifier.value.dy >=
                item.y! + (item.height! * 0.5)) &&
            (prov.valueNotifier.value.dy < item.y!));

    bool x = (item.placeHolderAt == PlaceHolderAt.top
        ? item.height != item.actualSize!.height
        : true);

    return
        // false&&
        willPlaceHolderAtBottom &&
            item.placeHolderAt != PlaceHolderAt.bottom &&
            prov.board.dragItemOfListIndex! == listIndex &&
            item.addedBySystem != true &&
            x;
  }

  bool getYAxisCondition({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];
    bool value = (_topPlaceHolderPossibility(listIndex, itemIndex) ||
            _bottomPlaceHolderPossibility(listIndex, itemIndex)) &&
        prov.board.dragItemOfListIndex! == listIndex;
    return value && item.addedBySystem != true;
  }

  bool getXAxisCondition({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);

    var right = ((prov.draggedItemState!.width * 0.6) +
                prov.valueNotifier.value.dx >
            prov.board.lists[listIndex].x!) &&
        ((prov.board.lists[listIndex].x! + prov.board.lists[listIndex].width! >
            prov.draggedItemState!.width + prov.valueNotifier.value.dx)) &&
        (prov.board.dragItemOfListIndex != listIndex);
    var left = (((prov.draggedItemState!.width) + prov.valueNotifier.value.dx >
            prov.board.lists[listIndex].x! +
                prov.board.lists[listIndex].width!) &&
        ((prov.draggedItemState!.width * 0.6) + prov.valueNotifier.value.dx <
            prov.board.lists[listIndex].x! +
                prov.board.lists[listIndex].width!) &&
        (prov.board.dragItemOfListIndex != listIndex));

    return (left || right);
  }

  void checkForXAxisMovement({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];

    var canReplaceCurrent = ((prov.valueNotifier.value.dy >= item.y!) &&
        (item.height! + item.y! >
            prov.valueNotifier.value.dy + (prov.draggedItemState!.height / 2)));
    var willPlaceHolderAtBottom = (itemIndex ==
            prov.board.lists[listIndex].items.length - 1 &&
        ((prov.draggedItemState!.height * 0.6) + prov.valueNotifier.value.dy >
            item.y! + item.height!));

    if (canReplaceCurrent || willPlaceHolderAtBottom) {
      //   log("X AXIS");
      prov.move = "other";

      resetCardWidget();

      item.placeHolderAt =
          willPlaceHolderAtBottom ? PlaceHolderAt.bottom : PlaceHolderAt.top;
      if (willPlaceHolderAtBottom) {
        prov.move = "LAST";
        // log("BOTTOM PLACEHOLDER X AXIS");
      }

      var isItemHidden = itemIndex - 1 >= 0 &&
          prov.draggedItemState!.itemIndex == itemIndex - 1 &&
          prov.draggedItemState!.listIndex == listIndex;

      // if (!isItemHidden) {
      addPlaceHolder(listIndex: listIndex, itemIndex: itemIndex);
      //   }
      if (isPrevSystemCard(listIndex: listIndex, itemIndex: itemIndex)) return;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        prov.board.lists[prov.board.dragItemOfListIndex!]
            .items[prov.board.dragItemIndex!].setState!();
        if (isItemHidden) {
          prov.move = "DOWN";
        }
        prov.board.dragItemIndex = itemIndex;
        prov.board.dragItemOfListIndex = listIndex;
        // log("UPDATED | ITEM= $listIndex | LIST= $itemIndex");
        item.setState!();
      });
    }
  }

  void onLongpressCard(
      {required int listIndex,
      required int itemIndex,
      required BuildContext context,
      required VoidCallback setsate}) {
    var prov = ref.read(ProviderList.boardProvider);
    final draggableProv = ref.read(ProviderList.draggableNotifier.notifier);
    var box = context.findRenderObject() as RenderBox;
    var location = box.localToGlobal(Offset.zero);
    prov.board.lists[listIndex].items[itemIndex].x =
        location.dx - prov.board.displacementX!;
    prov.board.lists[listIndex].items[itemIndex].y =
        location.dy - prov.board.displacementY!;
    // prov.board.lists[listIndex].items[itemIndex].width = box.size.width;
    // prov.board.lists[listIndex].items[itemIndex].height = box.size.height;
    prov.updateValue(
        dx: location.dx - prov.board.displacementX!,
        dy: location.dy - prov.board.displacementY!);
    prov.board.dragItemIndex = itemIndex;
    prov.board.dragItemOfListIndex = listIndex;
    draggableProv.setDraggableType(DraggableType.card);
    prov.draggedItemState = DraggedItemState(
        child: SizedBox(
          width:
              prov.board.lists[listIndex].items[itemIndex].context!.size!.width,
          child: prov.board.lists[listIndex].items[itemIndex].child,
        ),
        listIndex: listIndex,
        itemIndex: itemIndex,
        height: box.size.height - 10,
        width: box.size.width,
        x: location.dx,
        y: location.dy);
    prov.draggedItemState!.setState = setsate;
    // log("${listIndex} ${itemIndex}");
    setsate();
  }

  bool isCurrentElementDragged(
      {required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);
    final draggableProv = ref.read(ProviderList.draggableNotifier);

    return draggableProv.isCardDragged &&
        prov.draggedItemState!.itemIndex == itemIndex &&
        prov.draggedItemState!.listIndex == listIndex;
  }

  void saveNewCard() {
    var boardProv = ref.read(ProviderList.boardProvider);
    final cardState = boardProv.newCardState;
    boardProv.board.lists[cardState.listIndex!].items[cardState.cardIndex!]
        .child = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Text(boardProv.newCardState.textController.text,
          style: boardProv.board.textStyle),
    );
    boardProv.board.lists[cardState.listIndex!].items[cardState.cardIndex!]
            .prevChild =
        boardProv.board.lists[cardState.listIndex!].items[cardState.cardIndex!]
            .child;
    cardState.isFocused = false;
    boardProv.board.lists[cardState.listIndex!].items[cardState.listIndex!]
        .isNew = false;
    boardProv.newCardState.textController.clear();
    boardProv.board.lists[cardState.listIndex!].items[cardState.listIndex!]
        .setState!();
    cardState.cardIndex = null;
    cardState.listIndex = null;
    log("TAPPED");
  }

  void reorderCard() {
    var boardProv = ref.read(ProviderList.boardProvider);
    BoardList list =
        boardProv.board.lists[boardProv.board.dragItemOfListIndex!];
    ListItem card = list.items[boardProv.board.dragItemIndex!];
    card.child = card.prevChild;

    if (boardProv.draggedItemState!.listIndex ==
        boardProv.board.dragItemOfListIndex!) {
      list.items.insert(
          boardProv.board.dragItemIndex!,
          boardProv.board.lists[boardProv.draggedItemState!.listIndex!].items
              .removeAt(boardProv.draggedItemState!.itemIndex!));
    } else {
      if (card.placeHolderAt == PlaceHolderAt.bottom) {
        list.items.insert(
            boardProv.board.dragItemIndex! + 1,
            boardProv.board.lists[boardProv.draggedItemState!.listIndex!].items
                .removeAt(boardProv.draggedItemState!.itemIndex!));
      } else {
        list.items.insert(
            boardProv.board.dragItemIndex!,
            boardProv.board.lists[boardProv.draggedItemState!.listIndex!].items
                .removeAt(boardProv.draggedItemState!.itemIndex!));
      }
    }

    card.placeHolderAt = PlaceHolderAt.none;
  }
}

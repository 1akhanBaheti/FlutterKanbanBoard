import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
        .items[prov.board.dragItemIndex!].bottomPlaceholder = false;
    prov.board.lists[prov.board.dragItemOfListIndex!]
        .items[prov.board.dragItemIndex!].containsPlaceholder = false;
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
    if (item.context == null || list.context == null || !item.context!.mounted)
      return true;
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
    item.containsPlaceholder = true;
    item.child = Column(
      children: [
        !item.bottomPlaceholder!
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(6),
                  color: item.backgroundColor ?? Colors.white,
                ),
                margin: const EdgeInsets.only(
                    bottom: 15, left: 10, right: 10, top: 15),
                width: prov.draggedItemState!.width,
                height: prov.draggedItemState!.height,
                // child: Center(
                //   child: Text(
                //     itemIndex.toString(),
                //     style: GoogleFonts.firaSans(
                //         fontSize: 20, fontWeight: FontWeight.bold),
                //   ),
                // ),
              )
            : Container(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade100),
            borderRadius: BorderRadius.circular(6),
            color: item.backgroundColor ?? Colors.white,
          ),
          margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          width: item.actualSize!.width,
          child: item.prevChild,
        ),
        item.bottomPlaceholder!
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(6),
                  color: item.backgroundColor ?? Colors.white,
                ),
                margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
                width: prov.draggedItemState!.width,
                height: prov.draggedItemState!.height,
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

    var willPlaceHolderAtBottom = (itemIndex ==
            prov.board.lists[listIndex].items.length - 1 &&
        ((prov.draggedItemState!.height * 0.6) + prov.valueNotifier.value.dy >
            item.y! + item.height!));

    var willPlaceHolderAtTop =
        (((prov.draggedItemState!.height * 0.6) + prov.valueNotifier.value.dy <
                item.y! + item.height!) &&
            (prov.draggedItemState!.height + prov.valueNotifier.value.dy >
                item.y! + item.height!));

    if (((willPlaceHolderAtTop || willPlaceHolderAtBottom) &&
            prov.board.dragItemOfListIndex! == listIndex) &&
        (prov.board.dragItemIndex != itemIndex ||
            (willPlaceHolderAtBottom &&
                !prov.board.lists[listIndex].items[itemIndex]
                    .bottomPlaceholder!) ||
            (prov.board.lists[listIndex].items[itemIndex].bottomPlaceholder! &&
                itemIndex == prov.board.lists[listIndex].items.length - 1))) {
      if (willPlaceHolderAtBottom && item.bottomPlaceholder!) return;

      if (prov.board.dragItemIndex! < itemIndex && prov.move != 'other') {
        prov.move = "DOWN";
      }

      resetCardWidget();

      item.bottomPlaceholder = willPlaceHolderAtBottom;
      if (willPlaceHolderAtBottom) {
        prov.move = "LAST";
      }
      var isItemHidden = itemIndex - 1 >= 0 &&
          prov.draggedItemState!.itemIndex == itemIndex - 1 &&
          prov.draggedItemState!.listIndex == listIndex;

      if ((item.addedBySystem == null || !item.addedBySystem!)) {
        addPlaceHolder(listIndex: listIndex, itemIndex: itemIndex);
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
        prov.board.dragItemIndex = itemIndex;
        prov.board.dragItemOfListIndex = listIndex;
        prov.board.lists[prov.board.dragItemOfListIndex!].items[temp]
            .setState!();
      //  log("UP/DOWN $listIndex $itemIndex");
        item.setState!();
      });
    }
  }

  bool getYAxisCondition({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);
    var item = prov.board.lists[listIndex].items[itemIndex];
    var willPlaceHolderAtBottom = (itemIndex ==
            prov.board.lists[listIndex].items.length - 1 &&
        ((prov.draggedItemState!.height * 0.6) + prov.valueNotifier.value.dy >
            item.y! + item.height!));

    var willPlaceHolderAtTop =
        (((prov.draggedItemState!.height * 0.6) + prov.valueNotifier.value.dy <
                item.y! + item.height!) &&
            (prov.draggedItemState!.height + prov.valueNotifier.value.dy >
                item.y! + item.height!));

    return (((willPlaceHolderAtTop || willPlaceHolderAtBottom) &&
            prov.board.dragItemOfListIndex! == listIndex) &&
        (prov.board.dragItemIndex != itemIndex ||
            (willPlaceHolderAtBottom &&
                !prov.board.lists[listIndex].items[itemIndex]
                    .bottomPlaceholder!) ||
            (prov.board.lists[listIndex].items[itemIndex].bottomPlaceholder! &&
                itemIndex == prov.board.lists[listIndex].items.length - 1)));
  }

  bool getXAxisCondition({required int listIndex, required int itemIndex}) {
    var prov = ref.read(ProviderList.boardProvider);

    var left = ((prov.draggedItemState!.width * 0.6) +
                prov.valueNotifier.value.dx >
            prov.board.lists[listIndex].x!) &&
        ((prov.board.lists[listIndex].x! + prov.board.lists[listIndex].width! >
            prov.draggedItemState!.width + prov.valueNotifier.value.dx)) &&
        (prov.board.dragItemOfListIndex != listIndex);
    var right = (((prov.draggedItemState!.width) + prov.valueNotifier.value.dx >
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
      log("LEFT");
      prov.move = "other";

      resetCardWidget();

      item.bottomPlaceholder = willPlaceHolderAtBottom;
      if (willPlaceHolderAtBottom) {
        prov.move = "LAST";
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
    prov.board.isElementDragged = true;
    prov.draggedItemState = DraggedItemState(
        child: Container(
          color: prov.board.lists[listIndex].items[itemIndex].backgroundColor ??
              Colors.white,
          width: box.size.width - 20,
          child: prov.board.lists[listIndex].items[itemIndex].child,
        ),
        listIndex: listIndex,
        itemIndex: itemIndex,
        height: box.size.height,
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

    return prov.board.isElementDragged &&
        prov.draggedItemState!.itemIndex == itemIndex &&
        prov.draggedItemState!.listIndex == listIndex;
  }

  void saveNewCard() {
    var boardProv = ref.read(ProviderList.boardProvider);
    boardProv.board.lists[boardProv.board.newCardListIndex!]
        .items[boardProv.board.newCardIndex!].child = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10, top: 8),
      padding: const EdgeInsets.all(8.0),
      child: Text(boardProv.board.newCardTextController.text,
          style: boardProv.board.textStyle),
    );
    boardProv.board.lists[boardProv.board.newCardListIndex!]
            .items[boardProv.board.newCardIndex!].prevChild =
        boardProv.board.lists[boardProv.board.newCardListIndex!]
            .items[boardProv.board.newCardIndex!].child;
    boardProv.board.newCardFocused = false;
    boardProv.board.lists[boardProv.board.newCardListIndex!]
        .items[boardProv.board.newCardIndex!].isNew = false;
    boardProv.board.newCardTextController.clear();
    boardProv.board.lists[boardProv.board.newCardListIndex!]
        .items[boardProv.board.newCardIndex!].setState!();
    boardProv.board.newCardIndex = null;
    boardProv.board.newCardListIndex = null;
    log("TAPPED");
  }

  void reorderCard() {
    var boardProv = ref.read(ProviderList.boardProvider);
    boardProv.board.lists[boardProv.board.dragItemOfListIndex!]
            .items[boardProv.board.dragItemIndex!].child =
        boardProv.board.lists[boardProv.board.dragItemOfListIndex!]
            .items[boardProv.board.dragItemIndex!].prevChild;

    // dev.log("MOVE=${prov.move}");
    if (boardProv.move == 'LAST') {
      //   dev.log("LAST");
      boardProv.board.lists[boardProv.board.dragItemOfListIndex!].items.add(
          boardProv.board.lists[boardProv.draggedItemState!.listIndex!].items
              .removeAt(boardProv.draggedItemState!.itemIndex!));
    } else if (boardProv.move == "REPLACE") {
      boardProv.board.lists[boardProv.board.dragItemOfListIndex!].items.clear();
      boardProv.board.lists[boardProv.board.dragItemOfListIndex!].items.add(
          boardProv.board.lists[boardProv.draggedItemState!.listIndex!].items
              .removeAt(boardProv.draggedItemState!.itemIndex!));
    } else {
      //dev.log("LAST ELSE =${prov.board.lists[prov.board.dragItemOfListIndex!].items.length}");
      // dev.log(
      //      "LENGTH= ${prov.board.lists[prov.board.dragItemOfListIndex!].items.length}");
      //  dev.log("DRAGGED INDEX =${prov.board.dragItemIndex!}");

      // dev.log(
      // "PLACING AT =${prov.move == "DOWN" ? prov.board.dragItemIndex! - 1 < 0 ? prov.board.dragItemIndex! : prov.board.dragItemIndex! - 1 : prov.board.dragItemIndex!}");
      boardProv.board.lists[boardProv.board.dragItemOfListIndex!].items.insert(
          boardProv.move == "DOWN"
              ? boardProv.board.dragItemIndex! - 1 < 0
                  ? boardProv.board.dragItemIndex!
                  : boardProv.board.dragItemIndex! - 1
              : boardProv.board.dragItemIndex!,
          boardProv.board.lists[boardProv.draggedItemState!.listIndex!].items
              .removeAt(boardProv.draggedItemState!.itemIndex!));
      // dev.log(
      // "LENGTH= ${prov.board.lists[prov.board.dragItemOfListIndex!].items.length}");
    }
    // prov.board.lists[prov.board.dragItemOfListIndex!].setState! ();
  }
}

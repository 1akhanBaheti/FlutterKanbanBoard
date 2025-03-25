import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/Provider/provider_list.dart';
import 'package:kanban_board/draggable/card_draggable.dart';
import 'package:kanban_board/draggable/draggable_state.dart';
import 'package:kanban_board/draggable/list_draggable.dart';
import '../models/inputs.dart';
import '../models/board.dart';
import '../models/board_list.dart';
import '../models/item_state.dart';

class BoardProvider extends ChangeNotifier {
  BoardProvider(ChangeNotifierProviderRef<BoardProvider> this.ref);
  Ref ref;
  ValueNotifier<Offset> valueNotifier = ValueNotifier<Offset>(Offset.zero);
  String move = "";
  DraggedItemState? draggedItemState;
  CardDraggable? cardDraggable;
  ListDraggable? listDraggable;
  NewCardState newCardState = NewCardState();
  Offset delta = const Offset(0, 0);

  late BoardState board;
  var scrolling = false;
  var scrollingRight = false;
  var scrollingLeft = false;

  void initializeBoard(
      {required List<BoardListsData> data,
      Color backgroundColor = Colors.white,
      TextStyle? textStyle,
      Function(int? itemIndex, int? listIndex)? onItemTap,
      Function(int? itemIndex, int? listIndex)? onItemLongPress,
      Function(int? listIndex)? onListTap,
      Function(int? listIndex)? onListLongPress,
      double? displacementX,
      double? displacementY,
      void Function(int? oldCardIndex, int? newCardIndex, int? oldListIndex,
              int? newListIndex)?
          onItemReorder,
      void Function(int? oldListIndex, int? newListIndex)? onListReorder,
      void Function(String? oldName, String? newName)? onListRename,
      void Function(String? cardIndex, String? listIndex, String? text)?
          onNewCardInsert,
      Decoration? boardDecoration,
      Decoration? listDecoration,
      Widget Function(Widget child, Animation<double> animation)?
          listTransitionBuilder,
      Widget Function(Widget child, Animation<double> animation)?
          cardTransitionBuilder,
      required Duration cardTransitionDuration,
      required Duration listTransitionDuration,
      Color? cardPlaceHolderColor,
      Color? listPlaceHolderColor,
      ScrollConfig? boardScrollConfig,
      ScrollConfig? listScrollConfig}) {
    board = BoardState(
        textStyle: textStyle,
        lists: [],
        displacementX: displacementX,
        displacementY: displacementY,
        onItemTap: onItemTap,
        onItemLongPress: onItemLongPress,
        onListTap: onListTap,
        onListLongPress: onListLongPress,
        onItemReorder: onItemReorder,
        onListReorder: onListReorder,
        onListRename: onListRename,
        onNewCardInsert: onNewCardInsert,
        boardScrollConfig: boardScrollConfig,
        listScrollConfig: listScrollConfig,
        transitionHandler: TransitionHandler(
            cardTransitionBuilder:
                cardTransitionBuilder ?? (child, animation) => child,
            listTransitionBuilder:
                listTransitionBuilder ?? (child, animation) => child,
            cardTransitionDuration: cardTransitionDuration,
            listTransitionDuration: listTransitionDuration),
        controller: ScrollController(),
        backgroundColor: backgroundColor,
        cardPlaceholderColor: cardPlaceHolderColor,
        listPlaceholderColor: listPlaceHolderColor,
        listDecoration: listDecoration,
        boardDecoration: boardDecoration);

    for (int i = 0; i < data.length; i++) {
      List<ListItem> listItems = [];
      for (int j = 0; j < data[i].items.length; j++) {
        listItems.add(ListItem(
            child: data[i].items[j],
            listIndex: i,
            index: j,
            prevChild: data[i].items[j]));
      }
      board.lists.add(BoardList(
          header: data[i].header,
          footer: data[i].footer,
          headerBackgroundColor: data[i].headerBackgroundColor,
          footerBackgroundColor: data[i].footerBackgroundColor,
          backgroundColor: data[i].backgroundColor,
          items: listItems,
          width: data[i].width,
          scrollController: ScrollController(),
          title: data[i].title ?? 'LIST ${i + 1}'));
    }
  }

  void updateValue({
    required double dx,
    required double dy,
  }) {
    valueNotifier.value = Offset(dx, dy);
  }

  void setsState() {
    notifyListeners();
  }

  void boardScroll() async {
    final draggableProv = ref.read(ProviderList.draggableNotifier);
    if ((draggableProv.draggableType == DraggableType.none) || scrolling) {
      return;
    }
    if (board.controller.offset < board.controller.position.maxScrollExtent &&
        valueNotifier.value.dx + (draggedItemState!.width / 2) >
            board.controller.position.viewportDimension - 100) {
      scrolling = true;
      scrollingRight = true;
      if (board.boardScrollConfig == null) {
        log("HEREEEE");
        await board.controller.animateTo(board.controller.offset + 100,
            duration: const Duration(milliseconds: 100), curve: Curves.linear);
      } else {
        await board.controller.animateTo(
            board.boardScrollConfig!.offset + board.controller.offset,
            duration: board.boardScrollConfig!.duration,
            curve: board.boardScrollConfig!.curve);
      }
      scrolling = false;
      scrollingRight = false;
      boardScroll();
    } else if (board.controller.offset > 0 && valueNotifier.value.dx <= 0) {
      scrolling = true;
      scrollingLeft = true;

      if (board.boardScrollConfig == null) {
        await board.controller.animateTo(board.controller.offset - 100,
            duration:
                Duration(milliseconds: valueNotifier.value.dx < 20 ? 50 : 100),
            curve: Curves.linear);
      } else {
        await board.controller.animateTo(
            board.controller.offset - board.boardScrollConfig!.offset,
            duration: board.boardScrollConfig!.duration,
            curve: board.boardScrollConfig!.curve);
      }

      scrolling = false;
      scrollingLeft = false;
      boardScroll();
    } else {
      return;
    }
  }
}

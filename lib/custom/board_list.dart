import 'package:boardview/custom/item.dart';
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
    var prov = ref.read(ProviderList.reorderProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    prov.board.lists[widget.index].context = context;
      var box = context.findRenderObject() as RenderBox;
      location = box.localToGlobal(Offset.zero);
    prov.board.lists[widget.index].x = location.dx;
    prov.board.lists[widget.index].y= location.dy;
    // prov.board.lists[widget.listIndex].items[widget.itemIndex].width = box.size.width;
    // prov.board.lists[widget.listIndex].items[widget.itemIndex].height = box.size.height;
    });
    return Container(
      margin: const EdgeInsets.only(right: 50),
      width: 300,
      color: Colors.grey[300],
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        controller: prov.board.lists[widget.index].scrollController,
        itemCount: prov.board.lists[widget.index].items.length,
        shrinkWrap: true,
        itemBuilder: (ctx, index) {
          return Item(
              itemIndex: index,
              listIndex: widget.index,
              widget: prov.board.lists[widget.index].items[index].child);
        },

        // itemCount: prov.items.length,
      ),
    );
  }
}

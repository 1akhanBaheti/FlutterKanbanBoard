// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kanban_board/models/board_list.dart';
// import 'package:kanban_board/provider/provider_list.dart';
// import 'package:kanban_board/src/widgets/textfield.dart';

// class NewList extends ConsumerStatefulWidget {
//   const NewList({super.key});

//   @override
//   ConsumerState<NewList> createState() => _NewListState();
// }

// class _NewListState extends ConsumerState<NewList> {
//   @override
//   Widget build(BuildContext context) {
//     final boardProv = ref.watch(ProviderList.boardProvider);
//     final boardListProv = ref.watch(ProviderList.boardListProvider);
//     return Container(
//       margin: const EdgeInsets.only(
//         top: 20,
//         left: 30,
//       ),
//       padding: const EdgeInsets.only(
//         bottom: 20,
//       ),
//       width: 300,
//       color: const Color.fromARGB(
//         255,
//         247,
//         248,
//         252,
//       ),
//       child: Wrap(
//         children: [
//           SizedBox(
//             height: 50,
//             width: 300,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     setState(() {
//                       boardListProv.showNewList = false;
//                       boardProv.newCardState.textController.clear();
//                     });
//                   },
//                   icon: const Icon(Icons.close),
//                 ),
//                 IconButton(
//                     onPressed: () {
//                       setState(() {
//                         boardListProv.showNewList = false;
//                         boardProv.board.groups.add(BoardList(
//                           width: 300,
//                           scrollController: ScrollController(),
//                           items: [],
//                           title: boardProv.newCardState.textController.text,
//                         ));
//                         boardProv.newCardState.textController.clear();
//                       });
//                     },
//                     icon: const Icon(Icons.done))
//               ],
//             ),
//           ),
//           Container(
//               width: 300,
//               color: Colors.white,
//               margin: const EdgeInsets.only(top: 20, right: 10, left: 10),
//               child: const TField()),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanban_board/Provider/draggable_provider.dart';

import 'list_item_provider.dart';

import 'board_list_provider.dart';
import 'board_provider.dart';

class ProviderList {
  static final boardProvider = ChangeNotifierProvider<BoardProvider>(
    (ref) => BoardProvider(ref),
  );
  static final cardProvider = ChangeNotifierProvider<ListItemProvider>(
    (ref) => ListItemProvider(ref),
  );
  static final boardListProvider = ChangeNotifierProvider<BoardListProvider>(
    (ref) => BoardListProvider(ref),
  );

  static final draggableNotifier =
      StateNotifierProvider<DraggableNotfier, DraggableProviderState>(
          (ref) => DraggableNotfier(ref));
}

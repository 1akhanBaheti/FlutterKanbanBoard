import 'package:boardview/Provider/list_item_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'board_list_provider.dart';
import 'reorder_provider.dart';

class ProviderList {

  static final reorderProvider = ChangeNotifierProvider<BoardProvider>(
    (ref) => BoardProvider(),
    
  );
static final cardProvider = ChangeNotifierProvider<ListItemProvider>(
    (ref) => ListItemProvider(ref),
    
  );
  static final boardListProvider = ChangeNotifierProvider<BoardListProvider>(
    (ref) => BoardListProvider(ref),
    
  );
}

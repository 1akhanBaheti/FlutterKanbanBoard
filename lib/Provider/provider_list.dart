import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reorder_provider.dart';

class ProviderList {

  static final reorderProvider = ChangeNotifierProvider<ReorderProvider>(
    (ref) => ReorderProvider(),
  );
}

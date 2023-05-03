import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoardListProvider extends ChangeNotifier{
  BoardListProvider(ChangeNotifierProviderRef<BoardListProvider> this.ref);
  Ref ref;
}
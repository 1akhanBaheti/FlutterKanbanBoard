
import 'package:kanban_board/src/controllers/controllers.dart';

class BoardStateControllerStorage{
  BoardStateControllerStorage._();
  static final BoardStateControllerStorage _instance = BoardStateControllerStorage._();
  static BoardStateControllerStorage get I => _instance;
  

  final Map<String, BoardStateController> _controllers = {};

  void addStateController(String key, BoardStateController controller){
    _controllers[key] = controller;
  }

  BoardStateController? getStateController(String key){
    return _controllers[key];
  }

  void removeStateController(String key){
    _controllers.remove(key);
  }
}
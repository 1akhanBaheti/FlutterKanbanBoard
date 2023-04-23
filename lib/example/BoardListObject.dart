import 'BoardItemObject.dart';

class BoardListObject{

  String? title;
  List<BoardItemObject>? items;

  BoardListObject({this.title,this.items}){
    title ??= "";
    items ??= [];
  }
}
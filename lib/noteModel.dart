import 'package:inota/baseModel.dart';

class Note {
  int id;
  String title;
  String content;
  String color;

  String toString() {
    return "{'id'=$id,title'=$title,content'=$content,color'=$color}";
  }
}

class NoteMdel extends BaseModel {
  String color;

  /// Appliquer une couleur
  setColor(String inColor) {
    color = inColor;
    notifyListeners();
  }
}

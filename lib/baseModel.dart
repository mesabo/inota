import 'package:scoped_model/scoped_model.dart';

class BaseModel extends Model {
  int stackIndex = 0;
  List entitiList = [];
  var entityIsEditing;

  ///@loaddata
  ///fonction qui charge les données à partir de la bd
  ///En gros elle actualise la vue
  loadData(String entity, dynamic bd) async {
    entitiList = await bd.getAll();
    notifyListeners();
  }

  ///@loaddata
  ///fonction qui charge les données à partir de la bd
  ///En gros elle actualise la vue
  setStackIndex(int inIndex) {
    stackIndex = inIndex;
    notifyListeners();
  }
}

import 'package:inota/noteModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'utils.dart' as utils;

class NoteDatabase {
  NoteDatabase._();

  static final NoteDatabase db = NoteDatabase._();

  // Création d'objet db comme privé
  Database _db;

  // getter pour initialiser le chargement de données
  Future get database async {
    if (_db = null) {
      _db = await initDb();
    }
    return _db;
  }

  /// initialisation de la base de donnée
  Future<Database> initDb() async {
    String sql = "CREATE TABLE IF NOT EXISTS notes("
        "id INTEGER PRIMARY KEY,"
        "title TEXT,"
        "content TEXT,"
        "color TEXT)";

    String path = join(utils.docsDir.path, 'notes.db');

    // création de la table et insertion de données
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDb, int version) async {
      await inDb.execute(sql);
    });
    return db;
  }

  /// Charger les note dépuis le map
  /// et attribution de valeur aux champs id,title,content et colo
  /// Nous utilisons le type note car nous renvoyons des données
  /// de type note,c-à-d id,title,content,color
  Note noteFromMap(Map map) {
    Note note = new Note();

    // Pour obtenir les valeur de la requete, nous
    // passerons par la note comme intermédiaire
    // de stockage de valeur en l'état
    //by @Mesabo
    note.id = map["id"];
    note.title = map["title"];
    note.content = map["content"];
    note.color = map["color"];

    return note;
  }

  /// Vue qu'il faut enregistrer les données comme json ou map
  /// nous devons donc prendre chaque enregistrement et mettre
  /// les données ensemble comme map. ei {key,value}
  /// Il est évident de prendre le type Map
  Map<String, dynamic> noteToMap(Note note) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = note.id;
    map['title'] = note.title;
    map['content'] = note.content;
    map['color'] = note.color;

    return map;
  }

  /// Maintenant que tout est pret, passons à l'enregistrement meme
  /// Le type future est nécessaire car c'est une
  /// action ui nécessite du temps et de l'espace mémoire...
  Future createNote(Note note) async {
    // instanciation
    Database db = await database;
    String sql = "SELECT MAX(id)+1 as id FROM notes";

    var val = await db.rawQuery(sql);
    int id =
        val.first['id']; // prendre le premier id,on n'est jamais trop prudent

    if (id == null) {
      // c-à-d une valeur trouvée
      id = 1;
    }

    //todo: à revoir cette partie en cas d'erreur car c'est de l'audace
    String sqlInsert =
        "INSERT INTO notes(id,title,content,color) VALUES(?,?,?,?)";
    int res = await db.rawInsert(
        sqlInsert, [id, note.id, note.title, note.content, note.color]);

    return res;
  }

  /// Il est important d'avoir une requete pour une seule note donnée
  /// Alors cette fonction est la bienvenue, toujours est-il que c'est au futur
  /// Nous retournons une valeur de type Note
  Future<Note> getNote(int noteId) async {
    Database db = await database; // appel du getter
    var record = await db.query("notes", where: "id = ?", whereArgs: [noteId]);
    // todo: en cas d'erreur, retourner seulement-> return noteFromMap(record.first);
    Note note = noteFromMap(record.first);
    return note;
  }

  /// Et si nous voulons toutes les notes pour les afficher ???
  /// Cette requete fera le job...en retournant une liste de valeurs.
  Future<List> getAll() async {
    Database db = await database;
    var records = await db.query("notes");
    // C'est vital de convertir le map en list
    var list =
        records.isNotEmpty ? records.map((m) => noteFromMap(m)).toList() : [];

    return list;
  }

  /// Pour rendre hommage aux maladroits, il faut permetre la mise à jour
  Future update(Note note) async {
    Database db = await database;
    //todo: en cas d'erreur vous savez qui faire...
    int result = await db.update("notes", noteToMap(note),
        where: "id = ?", whereArgs: [note.id]);
    return result;
  }

  /// Lorsque la vie devient désagréable, il est important d'avoir une
  /// fenetre ouverte, un espoir. Et bien cette fonction vous l'offre
  /// vous permettant de supprimer vos mauvais souvenirs :)
  Future deleteNote(int noteId) async {
    Database db = await database;
    int res = await db.delete('notes', where: "id = ?", whereArgs: [noteId]);

    return res;
  }

  /// J'ESPÈRE QUE VOUS AVEZ PRIS DU PLAISIR À COMPRENDRE....
  /// by MESABO,instagram: @mesabo19,twitter: @mesabo18,facebook: mesabo19,youtube:mesabo19
}

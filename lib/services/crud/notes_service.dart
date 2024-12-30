import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

// there is alot of asynchronous stuff, if we say open db its going to take some time which leads to async function.
class NotesService {
  Database? _db;

  List<DatabaseNote> _notes=[];
  //" 
  static final NotesService _shared= NotesService._sharedInstances();
  NotesService._sharedInstances(){
    _notesStreamController=StreamController<List<DatabaseNote>>.broadcast(
      onListen: () => {
        _notesStreamController.sink.add(_notes)
      },
    );
  }//private named initializer/constructor
  
  // Public factory constructor to provide access
  factory NotesService() => _shared; //whenever the NotesService is called _shared is thrown which than throws _sharedInstances which calls its private intitializer
  //"
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes=> _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser ({required String email}) async { //we need to keep the user ready
    try{
      final user= await getUser(email: email);
      return user;
    }on CouldNotFindUser{
      final createdUser= await createUser(email: email);
      return createdUser;
    } catch (e){
      rethrow;
    }
  }

  Future<void> _cacheNotes ()async {
      final allNotes= await getAllNotes();
      _notes= allNotes.toList();//adding to the list 
      _notesStreamController.add(_notes);// adding to the streamcontroller 
    }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    await getNote(id: note.id);
    // update DB 
    final updatesCounted = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if(updatesCounted==0){
      throw CouldNotUpdateNote();
    }
    else{
      final updateNote = await getNote(id: note.id);// we are calling getnote because the notes are updated now.
      _notes.removeWhere((note)=> note.id == updateNote.id);
      _notes.add(updateNote);
      _notesStreamController.add(_notes);
      return updateNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    //here we are not passing any parameter because we are asking for all the notes
    final db = _getDataBaseOrThrow();
    final notes = await db.query(
      noteTable,
    );

    return notes
        .map((noteRow) => DatabaseNote.fromRow(noteRow.cast<String, Object>()));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note= DatabaseNote.fromRow(notes.first.cast<String, Object>());
      _notes.removeWhere((note)=>note.id==id);
      _notes.add(note);//we always update the local cache 
      _notesStreamController.add(_notes);//and than we show it to the outside world ie UI.
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final numberOfDeletion = await db.delete(noteTable);
    _notes=[];
    _notesStreamController.add(_notes);
    return numberOfDeletion;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note)=>note.id==id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    //make sure the owner exist in the table with the correct id.
    final dbUser = await getUser(email: owner.email);
    
    if (dbUser.id != owner.id) {
      throw CouldNotFindUser();
    }
    print('we got the dbUser: $dbUser');
    //create the note
    const text = ' ';
    try {
    final noteId = await db.insert(noteTable, {
    userIdColumn: owner.id,
    textColumn: text,
    isSyncedWithCloudColumn: 1,
  });
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    print("returning note");
    return note;

} catch (e) {
  print('Error inserting note: $e');
  throw Exception(e);
  // Handle the error appropriately
}
  }

  //get user
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first.cast<String, Object>());
    }
  }

  //create User
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      // here the results value is a list if it is not empty that means there exists a email
      throw UserAlreadyExist();
    }
    final userID = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(id: userID, email: email);
  }

  //deleting a user
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      // we are assigning 1 here because email is unique in sqlite db,so 1 means exists and
      // 0 means not exists
      throw CouldNotDeleteUser;
    }
  }

  // so when the user tries to read something from the function it should know,
  // whether the db is open or not so it should throw an exception.
  Database _getDataBaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  //closing the database
  Future<void> close() async {
    final db = _db; //shifting local database value to sqlite
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

//we need to ensure that when we hot reload the notes view db is not opening again and again 
  Future<void> _ensureDbIsOpen() async {
    try{
      await open();
    }on DatabaseAlreadyOpenException{

    }
  }
  //Opening  the Database
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create user Table
      await db.execute(createUserTable);//sql query
      //create note Table
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID=$id, email=$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID=$id, userId=$userId, isSyncedWithCloud=$isSyncedWithCloud, text=$text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "testing.db";
const noteTable = "note"; //this is a table name defined in the sqlite
const userTable = "user"; //this is a table name defined in the sqlite
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	  "id"	INTEGER NOT NULL,
	  "email"	TEXT NOT NULL UNIQUE,
	  PRIMARY KEY("id" AUTOINCREMENT)
  );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';

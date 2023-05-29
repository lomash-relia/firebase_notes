// import 'dart:async';
//
// import 'package:mynotes/services/crud/crud_exceptions.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
//
// const dbname = 'notes.db';
//
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
//
// const userIdColumn = 'user_id';
// const noteTable = 'notes';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
//
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
// 	  "id"	INTEGER NOT NULL,
// 	  "email"	TEXT NOT NULL UNIQUE,
//   	PRIMARY KEY("id" AUTOINCREMENT)
//   );''';
// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "notes" (
//     "id"	INTEGER NOT NULL,
//     "user_id"	INTEGER NOT NULL,
//     "text"	TEXT,
//     "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//     PRIMARY KEY("id" AUTOINCREMENT),
//     FOREIGN KEY("user_id") REFERENCES "user"("id")
//   );''';
//
// class NoteService {
//   Database? _db;
//
//   List<DatabaseNote> _notes = [];
//
//   static final NoteService _shared = NoteService._sharedInstance();
//
//   NoteService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//
//   factory NoteService() => _shared;
//
//   late final StreamController<List<DatabaseNote>> _notesStreamController;
//
//   Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
//
//   Future<DatabaseUser> getOrCreateUser({required String email}) async {
//     //await Future.delayed(const Duration(seconds: 10));
//     try {
//       final user = await getUser(email: email);
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes;
//     _notesStreamController.add(_notes);
//   }
//
//   Database _getDbOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     }
//     return db;
//   }
//
//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       throw DatabaseAlreadyOpenException();
//     }
//   }
//
//   Future<void> open() async {
//     if (_db != null) {
//       // throw DatabaseAlreadyOpenException();
//       return;
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbname);
//
//       final db = await openDatabase(dbPath);
//       _db = db;
//
//       await db.execute(createUserTable);
//       await db.execute(createNoteTable);
//
//       //todo: solve _cacheNotes() -------------------
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDirectoryException();
//     }
//   }
//
//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     }
//     await db.close();
//     _db = null;
//   }
//
//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//
//     final db = _getDbOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isEmpty) {
//       throw CouldNotFindUser();
//     }
//     return DatabaseUser.fromRow(results.first);
//   }
//
//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }
//
//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });
//     return DatabaseUser(id: userId, email: email);
//   }
//
//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final deletedAccount = await db.delete(
//       userTable,
//       where: '',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedAccount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }
//
//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUser();
//     }
//     const text = '';
//     final noteId = await db.insert(
//       noteTable,
//       {
//         userIdColumn: owner.id.toInt(),
//         textColumn: text.toString(),
//         isSyncedWithCloudColumn: 1,
//       },
//     );
//
//     final note = DatabaseNote(
//       isSyncedWithCloud: true,
//       id: noteId,
//       userId: owner.id,
//       text: text,
//     );
//
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }
//
//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id is ?',
//       whereArgs: [id],
//     );
//     if (notes.isEmpty) {
//       throw CouldNotFindNote();
//     }
//     final note = DatabaseNote.fromRow(notes.first);
//     _notes.removeWhere((note) => note.id == id);
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }
//
//   Future<List<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final notes = await db.query(noteTable);
//     if (notes.isEmpty) {
//       throw CouldNotFindNote();
//     }
//     final notesList = notes
//         .map(
//           (noteRow) => DatabaseNote.fromRow(noteRow),
//         )
//         .toList();
//     return notesList;
//   }
//
//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     await getNote(id: note.id);
//     final updatesCount = await db.update(
//       noteTable,
//       {textColumn: text, isSyncedWithCloudColumn: 0},
//       where: 'id is ?',
//       whereArgs: [note.id],
//     );
//     if (updatesCount == 0) {
//       throw CouldNotUpdateNote();
//     }
//     final updatedNote = await getNote(id: note.id);
//     _notes.removeWhere((note) => note.id == updatedNote.id);
//     _notes.add(updatedNote);
//     _notesStreamController.add(_notes);
//     return updatedNote;
//   }
//
//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final deletedNote = await db.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedNote != 1) {
//       throw CouldNotDeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }
//
//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final numberOfDeletions = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }
// }
//
// class DatabaseUser {
//   final int id;
//   final String email;
//
//   DatabaseUser({
//     required this.id,
//     required this.email,
//   });
//
//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;
//
//   @override
//   String toString() => 'Person, id = $id, email = $email';
//
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;
//
//   DatabaseNote({
//     required this.isSyncedWithCloud,
//     required this.id,
//     required this.userId,
//     required this.text,
//   });
//
//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud = map[isSyncedWithCloudColumn] == 1 ? true : false;
//
//   @override
//   String toString() =>
//       'Note , id = $id, userId = $userId , text = $text , isSyncedWithCloud = $isSyncedWithCloud';
//
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }

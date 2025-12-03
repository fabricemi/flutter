import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDatabase() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'favoris.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cities(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          lat REAL,
          lon REAL
        );
      ''');

      await db.execute('''
        CREATE TABLE lieux(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          lat REAL,
          lon REAL,
          city TEXT
        );
      ''');
    },
  );
  return database;
}

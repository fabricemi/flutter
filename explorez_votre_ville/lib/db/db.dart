import 'dart:math';

import 'package:explorez_votre_ville/models/city.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _db;

Future<Database> initDatabase() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'mesfavoris.db'),
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

Future<Database> getDatabase() async {
  if (_db != null) {
    print("DB déjà initialisée");
    return _db!;
  }
  print("Initialisation de la DB...");
  _db = await initDatabase();
  print("DB initialisée");
  return _db!;
}

Future<void> inserLieu(Lieu f, {String? ville}) async {
  final exists = await existeCity(f.city);
  if (!exists) {
    final nom = ville != null ? ville : f.city;
    City city = City(name: nom, lat: f.cityLat!, lon: f.cityLon!);
    await inserVille(city);
  }
  final db = await getDatabase();
  await db.insert(
    'lieux',
    f.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<String> inserVille(City f) async {
  final db = await getDatabase();
  await db.insert(
    'cities',
    f.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  return f.name;
}

Future<bool> existeCity(String city) async {
  final db = await getDatabase();

  final List<Map<String, dynamic>> maps = await db.query(
    'cities',
    columns: ['name'],
    where: 'name = ?',
    whereArgs: [city],
  );
  return maps.isNotEmpty;
}

Future<List<City>> getCities() async {
  final db = await getDatabase();
  final List<Map<String, Object?>> favMaps = await db.query('cities');
  final l = [
    for (final {
          'id': id as int,
          'name': name as String,
          'lat': lat as double,
          'lon': lon as double,
        }
        in favMaps)
      City(id: id, name: name, lat: lat, lon: lon),
  ];
  print('la liste des villes : $l');
  return l;
}

Future<List<Lieu>> getLieux(String city) async {
  print("recherache $city");
  final db = await initDatabase();
  final List<Map<String, Object?>> favMaps = await db.query(
    'lieux',
    where: 'city = ?',
    whereArgs: [city],
  );
  final l = [
    for (final {
          'id': id as int,
          'name': name as String,
          'lat': lat as double,
          'lon': lon as double,
          "city": city as String,
        }
        in favMaps)
      Lieu(id: id, name: name, lat: lat, lon: lon, city: city),
  ];
  print('la liste des lieux : $l');
  return l;
}

Future<void> deleteDatabaseFile() async {
  final path = join(await getDatabasesPath(), 'mesfavoris.db');
  await deleteDatabase(path);
  print("Database supprimée !");
}

Future<List<City>> getRandomCity() async {
  final cities = await getCities();
  if (cities.isEmpty) {
    return [];
  }
  final random = Random().nextInt(cities.length);
  List<City> citi = [];
  citi.add(cities.elementAt(random));
  cities.clear();
  return citi;
}

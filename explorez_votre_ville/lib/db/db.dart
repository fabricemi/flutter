import 'dart:math';

import 'package:explorez_votre_ville/models/city.dart';
import 'package:explorez_votre_ville/models/commentaire.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _db;

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

      await db.execute('''
      CREATE TABLE commentaires(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lieu_id INTEGER NOT NULL,
        texte TEXT,
        note INTEGER,
        date_creation TEXT DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (lieu_id) REFERENCES lieux(id) ON DELETE CASCADE
      );
    ''');
    },
  );
  print("Objet : ${database.path}");
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

Future<bool> existeLieu(String name) async {
  final db = await getDatabase();
  final List<Map<String, dynamic>> maps = await db.query(
    'lieux',
    columns: ['name'],
    where: 'name = ?',
    whereArgs: [name],
  );
  return maps.isNotEmpty;
}

Future<void> inserLieu(Lieu f, {String? ville}) async {
  final existsLieu = await existeLieu(f.name);

  if (existsLieu) {
    print("actionné   ${f.name}");
    return;
  }

  final nom = (ville ?? f.city).toLowerCase();
  final exists = await existeCity(nom);
  print("on insère $nom");

  // insérer la ville si elle n'existe pas
  if (!exists) {
    City city = City(name: nom, lat: f.cityLat!, lon: f.cityLon!);
    await inserVille(city);
  } else {}

  f.city = nom;
  // insérer le lieu
  final db = await getDatabase();
  await db.insert(
    'lieux',
    f.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> inserVille(City f) async {
  // On normalise le nom
  final nameLower = f.name.toLowerCase();

  final exists = await existeCity(nameLower);

  if (exists) {
    return;
  }
  final db = await getDatabase();
  await db.insert('cities', {
    "name": nameLower,
    "lat": f.lat,
    "lon": f.lon,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<bool> existeCity(String city) async {
  final db = await getDatabase();
  final List<Map<String, dynamic>> maps = await db.query(
    'cities',
    columns: ['name'],
    where: 'LOWER(name) = ?',
    whereArgs: [city.toLowerCase()],
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

Future<List<Lieu>> getLieuxFavoris(String cityName) async {
  print("recherche $cityName");
  final db = await getDatabase();

  final List<Map<String, Object?>> favMaps = await db.query('lieux');

  final filteredMaps = favMaps.where((element) {
    final cityValue = (element['city'] as String?)?.toLowerCase();
    return cityValue == cityName.toLowerCase();
  }).toList();

  final l = [
    for (final {
          'id': id as int,
          'name': name as String,
          'lat': lat as double,
          'lon': lon as double,
          'city': city as String,
        }
        in filteredMaps)
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

Future<void> ajouterCommentaire(Lieu f, Commentaire com) async {
  final existsLieu = await existeLieu(f.name);

  if (!existsLieu) {
    return;
  }
  final db = await getDatabase();
  await db.insert(
    'commentaires',
    com.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> deleteLieu(int id) async {
  final db = await openDatabase('favoris.db');

  try {
    await db.delete('lieux', where: 'id = ?', whereArgs: [id]);
  } catch (e) {
    //print("Erreur lors de la suppression du lieu : $e");
  }
}

Future<List<Commentaire>> getComments(int idLieu) async {
  final db = await getDatabase();
  final favMaps = await db.query(
    'commentaires',
    where: 'lieu_id = ?',
    whereArgs: [idLieu],
  );

  final commentaires = favMaps.map((c) {
    return Commentaire(c['texte'] as String, idLieu, c['note'] as int? ?? 0);
  }).toList();

  print('la liste des commentaires : $commentaires');
  return commentaires;
}

Future<bool> isLieuFavori(String name) async {
  final db = await getDatabase();

  final result = await db.query(
    'lieux',
    columns: ['id'],
    where: 'name = ?',
    whereArgs: [name],
    limit: 1,
  );

  return result.isNotEmpty;
}

Future<String> getNote(int idLieu) async {
  final db = await getDatabase();
  final favMaps = await db.query(
    'commentaires',
    where: 'lieu_id = ?',
    whereArgs: [idLieu],
  );
  final commentaires = favMaps.map((c) {
    return Commentaire(c['texte'] as String, idLieu, c['note'] as int? ?? 0);
  }).toList();

  int somme = (commentaires
      .map<int>((e) {
        return e.note;
      })
      .reduce((value, element) => value + element));
  int n;
  if (commentaires.isEmpty) {
    n = 1;
  } else {
    n = (somme / commentaires.length).round();
  }
  return "$n/10";
}

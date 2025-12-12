import 'package:drift/drift.dart';

class Villes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
}

class Places extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  IntColumn get city =>
      integer().nullable().customConstraint("REFERENCES villes(id)")();
}

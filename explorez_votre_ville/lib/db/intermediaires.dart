import 'package:explorez_votre_ville/db/db.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
/* import 'package:explorez_votre_ville/db/drift_cust_db.dart';
;

//AppDatabase? _db;

Future<AppDatabase> getDatabase() async {
  //_db ??= AppDatabase(); // initialisation pareusseuse
  return AppDatabase();
}

Future<void> insererUnLieu(Lieu lieu) async {
  final db = await getDatabase();

  final res = await db.insertPlaces(lieu);
  final lieux = await db.getLesLieux();
  final villes = await db.getCities();

  print("$res les lieux $lieux");
  print("les villes $villes");
}
 */

Future<void> insererUnLieu(Lieu lieu, {String? ville}) async {
  if (ville != null) {
    await inserLieu(lieu, ville: ville);
  } else {
    await inserLieu(lieu);
  }
  //final lieux = await getLieux(lieu.city);
  //final villes = await getCities();

  //print("les lieux $lieux");
  //print("les villes $villes");
}

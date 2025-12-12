import 'package:explorez_votre_ville/listeners/lieu_provider.dart';
import 'package:explorez_votre_ville/screens/home_page.dart';
import 'package:explorez_votre_ville/screens/ajouter_commentaire.dart';
import 'package:explorez_votre_ville/screens/lieu_details.dart';
import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/screens/search_page.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
    ChangeNotifierProvider(create: (_) => LieuProvider(), child: const Base()),
  );
}

class Base extends StatelessWidget {
  const Base({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorez Votre Ville',
      initialRoute: "/",
      routes: {
        "/": (context) => HomePage(),
        "/search": (context) => SearchPage(),
        "/details": (context) => LieuDetails(),
        "/comm": (context) => CommenterEtNoter(),
      },
    );
  }
}

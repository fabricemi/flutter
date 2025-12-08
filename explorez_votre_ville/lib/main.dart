import 'package:explorez_votre_ville/screens/home_page.dart';
import 'package:explorez_votre_ville/screens/lieu_form_page.dart';
import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/screens/search_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit(); // Activation SQLite FFI
  databaseFactory = databaseFactoryFfi;

  runApp(const Base());
}

class Base extends StatelessWidget {
  const Base({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorez Votre Ville',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(),
        "/search": (context) => const SearchPage(),

        //  Route d'ajout manuel d'un lieu
        "/add-lieu": (context) {
          final city = ModalRoute.of(context)!.settings.arguments as String;
          return LieuFormPage(city: city);
        },

        // Route sélection sur carte (ajout futur)
        "/map-select": (context) {
          final city = ModalRoute.of(context)!.settings.arguments as String;
          return const Placeholder(); // TODO: remplacé quand tu veux
        },
      },
    );
  }
}

import 'package:explorez_votre_ville/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/screens/search_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const Base());
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
      },
    );
  }
}

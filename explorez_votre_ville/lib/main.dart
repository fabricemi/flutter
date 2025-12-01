import 'package:explorez_votre_ville/screens/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Base());
}

class Base extends StatelessWidget {
  const Base({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorez Votre Ville',
      initialRoute: "/",
      routes: {"/": (context) => HomePage()},
    );
  }
}

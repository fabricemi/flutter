import 'package:explorez_votre_ville/listeners/lieu_provider.dart';
import 'package:explorez_votre_ville/listeners/theme_provider.dart';
import 'package:explorez_votre_ville/listeners/recherche_providers.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LieuProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(
          create: (_) => RechercheProviders()
            ..loadFavoriteCity()
            ..loadRecentSearches(),
        ),
      ],
      child: const Base(),
    ),
  );
}

class Base extends StatelessWidget {
  const Base({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Explorez Votre Ville',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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

import 'package:explorez_votre_ville/db/db.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/widgets/dialogs_page.dart';
import 'package:explorez_votre_ville/widgets/place_plot.dart';
import 'package:explorez_votre_ville/widgets/places.dart';
import 'package:explorez_votre_ville/widgets/show_meteo.dart';
import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/models/meteo.dart';
import 'package:explorez_votre_ville/models/api_cals.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _latLng = const LatLng(48.8566, 2.3522);
  List<PlacePlot> lieux = [];

  @override
  void initState() {
    super.initState();
    _getRandomFavoris();
    _loadLieux();
  }

  // Ville aléatoire enregistrée localement
  void _getRandomFavoris() async {
    final city = await getRandomCity();
    if (city.isEmpty) {
      _controller.text = "Paris";
      _latLng = const LatLng(48.8566, 2.3522);
      return;
    }
    _controller.text = city.first.name;
    _latLng = LatLng(city.first.lat, city.first.lon);
  }

  // Recherche API
  void _searchCity() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez une ville valide")),
      );
      return;
    }

    try {
      final loc = await getCoordinates(_controller.text);
      if (loc.isNotEmpty) {
        setState(() => _latLng = LatLng(loc[0], loc[1]));
        _mapController.move(_latLng, 12);
        _loadLieux();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  // Chargement des lieux via Geoapify
  Future<void> _loadLieux() async {
    try {
      final data = await getCityPlaces(_latLng.latitude, _latLng.longitude);
      setState(() {
        lieux = data.map((e) => PlacePlot(e: e)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  Future<void> _loadLieuxByCategory(String cat) async {
    try {
      final data = await getCityPlacesAvecCategorie(
        _latLng.latitude,
        _latLng.longitude,
        cat,
      );
      setState(() {
        lieux = data.map((e) => PlacePlot(e: e)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  // Menu d'ajout
  void _openAddLieuMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_location_alt),
                title: const Text("Ajouter manuellement"),
                subtitle: const Text("Formulaire + sélection sur carte"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    "/add-lieu",
                    arguments: _controller.text.trim(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text("Ajouter via une catégorie"),
                onTap: () async {
                  Navigator.pop(context);
                  final cat = await showCategoriesDialog(context);
                  if (cat != null) _loadLieuxByCategory(cat);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rechercher une ville"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            tooltip: "Ajouter un lieu",
            onPressed: _openAddLieuMenu,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Entrez une ville (ex: Paris)",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _searchCity(),
            ),

            const SizedBox(height: 20),

            // Affichage météo
            FutureBuilder(
              future: fetchCityInfoFromOWM(_controller.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text("Erreur météo",
                      style: TextStyle(color: Colors.red));
                }
                if (!snapshot.hasData) return const SizedBox.shrink();
                return ShowMeteo(meteo: snapshot.data as Meteo);
              },
            ),

            const SizedBox(height: 20),

            // Carte
            SizedBox(
              height: 400,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _latLng,
                  initialZoom: 11,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _latLng,
                        child: const Icon(Icons.location_on,
                            color: Colors.blue, size: 40),
                      ),
                    ],
                  ),
                  ...lieux,
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text("Les Favoris"),

            FutureBuilder(
              future: getLieux(_controller.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text("Erreur favoris");
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) return const Text("Aucun favori");

                return PlacesListView(favoris: data);
              },
            ),
          ],
        ),
      ),
    );
  }
}

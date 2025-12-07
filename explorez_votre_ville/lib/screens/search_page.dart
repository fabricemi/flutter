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
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final MapController _mapController = MapController();
  bool initialisation = true;
  LatLng _latLng = LatLng(48.8566, 2.3522);
  List<PlacePlot> lieux = [];

  List<Lieu> lieuxInfos = []; // Pour afficher une liste lisible

  @override
  void initState() {
    super.initState();
    _getRandomFavoris();
    _loadLieux();
  }

  /// Localisation GPS (non utilisée pour l'instant)
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activer le service de localisation')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation bloquée')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _latLng = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_latLng, 12.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la récupération de la localisation'),
        ),
      );
    }
  }

  void _getRandomFavoris() async {
    final city = await getRandomCity();
    if (city.isEmpty) {
      _controller.text = "Paris";
      _latLng = LatLng(48.8566, 2.3522);
      return;
    }
    _controller.text = city.first.name;
    _latLng = LatLng(city.first.lat, city.first.lon);
    initialisation = false;
  }

  void _searchCity() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Entrez une ville valide")));
      return;
    }

    try {
      List<double> location = await getCoordinates(_controller.text);

      if (location.isNotEmpty) {
        setState(() {
          _latLng = LatLng(location[0], location[1]);
        });

        _mapController.move(_latLng, 12.0);
        _loadLieux();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  /// Charger les lieux proches d’une ville
  Future<void> _loadLieux() async {
    try {
      final value = await getCityPlaces(_latLng.latitude, _latLng.longitude);
      //await initDatabase();
      setState(() {
        //lieuxInfos = value;

        lieux = value.map((e) {
          return PlacePlot(e: e);
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<void> _loadLieux2(String categorie) async {
    try {
      final value = await getCityPlacesAvecCategorie(
        _latLng.latitude,
        _latLng.longitude,
        categorie,
      );

      setState(() {
        //lieuxInfos = value;

        lieux = value.map((e) {
          return PlacePlot(e: e);
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rechercher une ville")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Champ de recherche
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

              /// Affichage météo
              FutureBuilder(
                future: fetchCityInfoFromOWM(_controller.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    );
                  } else if (!snapshot.hasData) {
                    return const Text('Aucune donnée.');
                  } else {
                    Meteo meteo = snapshot.data!;
                    return _buildCityInfo(meteo);
                  }
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final resultat = await showCategoriesDialog(context);
                  if (resultat != null) {
                    _loadLieux2(resultat);
                  }
                },
                icon: Icon(Icons.add_location_alt),
                label: Text("Ajouter un lieu"),
              ),

              const SizedBox(height: 25),

              /// Carte + marqueurs
              SizedBox(
                height: 400,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _latLng,
                    initialZoom: 10.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                      subdomains: const ['a', 'b', 'c', 'd'],
                      retinaMode: RetinaMode.isHighDensity(context),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _latLng,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    ...lieux,
                  ],
                ),
              ),

              const SizedBox(height: 25),
              Text("Les Favoris"),

              ///cette partie est à ameliorer
              FutureBuilder(
                future: getLieux(_controller.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    final data = snapshot.data!;
                    if (data.isEmpty) {
                      return Text("Aucun lieu favoris");
                    } else {
                      return PlacesListView(favoris: data);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildCityInfo(Meteo meteo) {
  return ShowMeteo(meteo: meteo);
}

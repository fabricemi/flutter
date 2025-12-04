import 'package:explorez_votre_ville/models/lieu.dart';
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
  final TextEditingController _controller = TextEditingController(text: "Paris");
  final MapController _mapController = MapController();

  LatLng _latLng = LatLng(48.8566, 2.3522);
  List<MarkerLayer> lieux = [];
  List<Lieu> lieuxInfos = []; // Pour afficher une liste lisible

  @override
  void initState() {
    super.initState();
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
            content: Text('Erreur lors de la récupération de la localisation')),
      );
    }
  }

  /// Recherche ville → coordonnées
  void _searchCity() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez une ville valide")),
      );
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  /// Charger les lieux proches d’une ville
  Future<void> _loadLieux() async {
    try {
      final value =
      await getCityPlaces(_latLng.latitude, _latLng.longitude);

      setState(() {
        lieuxInfos = value;

        lieux = value.map((e) {
          return MarkerLayer(
            markers: [
              Marker(
                point: LatLng(e.lat, e.lon),
                child: const Icon(Icons.location_on,
                    color: Colors.red, size: 40),
              ),
            ],
          );
        }).toList();
      });
    } catch (e) {
      print("Erreur chargement lieux : $e");
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
                    return Text(snapshot.error.toString(),
                        style: const TextStyle(
                            color: Colors.red, fontSize: 16));
                  } else if (!snapshot.hasData) {
                    return const Text('Aucune donnée.');
                  } else {
                    Meteo meteo = snapshot.data!;
                    return _buildCityInfo(meteo);
                  }
                },
              ),

              const SizedBox(height: 20),

              /// Bouton Ajouter un lieu
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Fonction Ajouter un lieu à implémenter")),
                  );
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

              /// Liste des lieux trouvés
              if (lieuxInfos.isNotEmpty)
                const Text("Lieux trouvés à proximité :",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: lieuxInfos.length,
                itemBuilder: (context, index) {
                  final l = lieuxInfos[index];
                  return ListTile(
                    leading: Icon(Icons.place, color: Colors.red),
                    title: Text(l.name.isEmpty ? "Lieu ${index + 1}" : l.name),
                    subtitle: Text("Lat: ${l.lat}, Lon: ${l.lon}"),
                  );
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

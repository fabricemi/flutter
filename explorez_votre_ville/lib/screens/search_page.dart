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
  final TextEditingController _controller = TextEditingController(
    text: "Paris",
  );
  final MapController _mapController = MapController();
  LatLng _latLng = LatLng(48.8566, 2.3522);
  List<MarkerLayer> lieux = [];

  @override
  void initState() {
    super.initState();
    //_getCurrentLocation();
    _loadLieux();
  }

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

      /*  getCityWithCoordonates(position.latitude, position.longitude).then((
        value,
      ) {
        _controller.text = value.city;
        _searchCity();
        getCityPlaces(value);
      });
 */
      _mapController.move(_latLng, 12.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'obtention de la localisation'),
        ),
      );
    }
  }

  // Fonction appelée quand on tape une ville
  void _searchCity() async {
    try {
      if (_controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Entrez une ville valide")),
        );
        return;
      }

      List<double> location = await getCoordinates(_controller.text);

      if (location.isNotEmpty) {
        setState(() {
          _latLng = LatLng(location[0], location[1]);
        });
        _mapController.move(_latLng, 12.0);
        _loadLieux();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune position trouvée pour cette ville.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du géocodage : ${e.toString()}')),
      );
    }
  }

  Future<void> _loadLieux() async {
    final value = await getCityPlaces(_latLng.latitude, _latLng.longitude);
    print("called");
    setState(() {
      lieux = value.map((e) {
        return MarkerLayer(
          markers: [
            Marker(
              point: LatLng(e.lat, e.lon),
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    /* getCityPlaces(_latLng.latitude, _latLng.longitude).then((value) {
      lieux.clear();
      for (var e in value) {
        lieux.add(
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(e.lat, e.lon),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      }
    }); */
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

              FutureBuilder(
                future: fetchCityInfoFromOWM(_controller.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    );
                  } else if (!snapshot.hasData) {
                    return Text('Aucune donnée.');
                  } else {
                    Meteo meteo = snapshot.data!;

                    print("$lieux");
                    return _buildCityInfo(meteo);
                  }
                },
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

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
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    ...lieux,
                  ],
                ),
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

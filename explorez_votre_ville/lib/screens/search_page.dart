import 'package:explorez_votre_ville/db/db.dart';
import 'package:explorez_votre_ville/listeners/lieu_provider.dart';
import 'package:explorez_votre_ville/listeners/recherche_providers.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/widgets/dialogs_page.dart';
import 'package:explorez_votre_ville/widgets/place_plot.dart';
import 'package:explorez_votre_ville/widgets/places.dart';
import 'package:explorez_votre_ville/widgets/searche_by_name.dart';
import 'package:explorez_votre_ville/widgets/show_meteo.dart';
import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/models/meteo.dart';
import 'package:explorez_votre_ville/models/api_cals.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:explorez_votre_ville/listeners/theme_provider.dart';
import 'package:explorez_votre_ville/listeners/recherche_providers.dart';



class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _latLng = LatLng(48.8566, 2.3522);
  List<PlacePlot> lieux = [];
  Future<List<Lieu>> _futurListLieux = Future.value([]);
  Future<List<Lieu>> _futurListLieuxTrouve = Future.value([]);

  Future<Meteo>? _meteo;

  String? ville;

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
      _futurListLieux = Future.value([]);
    } else {
      _controller.text = city.first.name;
      _latLng = LatLng(city.first.lat, city.first.lon);
      _futurListLieux = getLieux(_controller.text);
    }
    //getPlaceByName("le louvre", 48.8566, 2.3522, "Paris");
    setState(() {
      _meteo = fetchCityInfoFromOWM(_controller.text);
    });
    _mapController.move(_latLng, 12.0);
    _loadLieux();
  }

  void _searchCity() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Entrez une ville valide")));
      return;
    }

    ville = _controller.text;
    context.read<RechercheProviders>().addRecentSearch(_controller.text);


    try {
      List<double> location = await getCoordinates(_controller.text);

      if (location.isNotEmpty) {
        setState(() {
          _latLng = LatLng(location[0], location[1]);
          _meteo = fetchCityInfoFromOWM(_controller.text);
          _futurListLieux = getLieux(_controller.text);
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

  void _insert(Lieu e, {String? v}) async {
    print("debut");
    if (ville != null) {
      await inserLieu(e, ville: v);
    } else {
      await inserLieu(e);
    }
    print("fin");

    setState(() {
      _futurListLieux = getLieux(_controller.text);
    });
  }

  /// Charger les lieux proches d’une ville
  Future<void> _loadLieux() async {
    final value = await getCityPlaces(_latLng.latitude, _latLng.longitude);
    setState(() {
      lieux = value.map((e) {
        return PlacePlot(
          e: e,
          onTap: (lieu) {
            _insert(e, v: _controller.text);
          },
        );
      }).toList();
    });
  }

  Future<void> _loadLieux2(String categorie) async {
    final value = await getCityPlacesAvecCategorie(
      _latLng.latitude,
      _latLng.longitude,
      categorie,
      ville: _controller.text,
    );
    setState(() {
      lieux = value.map((e) {
        return PlacePlot(
          e: e,
          onTap: (lieu) {
            _insert(e, v: _controller.text);
          },
        );
      }).toList();
    });
  }

  Future<void> _feedSearchLieuList(String value) async {
    setState(() {
      _futurListLieuxTrouve = getPlaceByName(
        value,
        _latLng.latitude,
        _latLng.longitude,
        _controller.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rechercher une ville"),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
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
                future: _meteo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (_meteo == null) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    print("error ${snapshot.error.toString()}");
                    return Text(
                      "Erreur ... ${snapshot.error.toString()}",
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

              Wrap(
                direction: Axis.horizontal,
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Recherche un lieu dans la ville de ${_controller.text}",
                            ),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: AddLieuComplted(
                                city: _controller.text,
                                latLng: _latLng,
                                onAddLieuCalled: (lieu) {
                                  _insert(lieu, v: _controller.text);
                                },
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Fermer"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.add_location_alt),

                    label: Text("Ajouter un lieu par le nom"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final categorie = await showCategoriesDialog(context);
                      if (categorie != null) {
                        _loadLieux2(categorie);
                      }
                    },
                    icon: Icon(Icons.add_location_alt),

                    label: Text("Ajouter un lieu par categorie"),
                  ),
                ],
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
              FutureBuilder<List<Lieu>>(
                future: _futurListLieux,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Aucun lieu favoris');
                  } else {
                    return PlacesListView(favoris: snapshot.data!);
                    /* Consumer<LieuProvider>(
                      builder: (context, value, child) {
                        return PlacesListView(
                          favoris: snapshot.data!,
                          onVoirClicked: (l) {
                            value.changerLieu(l);
                            Navigator.pushNamed(context, "/details");
                          },
                        );
                      },
                    ); */
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

import 'package:explorez_votre_ville/db/db.dart';
import 'package:explorez_votre_ville/listeners/lieu_provider.dart';
import 'package:explorez_votre_ville/listeners/theme_provider.dart';
import 'package:explorez_votre_ville/models/api_cals.dart';
import 'package:explorez_votre_ville/models/commentaire.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class LieuDetails extends StatefulWidget {
  const LieuDetails({super.key});

  @override
  State<LieuDetails> createState() => _LieuDetailsState();
}

class _LieuDetailsState extends State<LieuDetails> {
  final MapController _mapController = MapController();
  LieuInfo? info;
  bool _loadingInfo = false;

  void _getInfo(Lieu lieu) async {
    if (_loadingInfo) {
      return;
    }
    _loadingInfo = true;
    final value = await getLieuInfo(lieu.lat, lieu.lon);
    if (value != null) {
      setState(() {
        info = value;
      });
    }
    await getImage(lieu.lat, lieu.lon);
  }

  @override
  Widget build(BuildContext context) {
    final lieuProvider = Provider.of<LieuProvider>(context);
    final lieu = lieuProvider.lieu;

    if (lieu == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Aucun lieu selectionné",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.arrow_back),
                label: const Text("Retourner à la recherche"),
              ),
            ],
          ),
        ),
      );
    }

    _getInfo(lieu);

    LatLng latLng = LatLng(lieu.lat, lieu.lon);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Détails du lieu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        leading: Consumer<LieuProvider>(
          builder: (context, value, _) {
            return IconButton(
              tooltip: "Retour à la recherche",
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),

        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                tooltip: "Changer le thème",
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: themeProvider.toggleTheme,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Détails du lieu ${lieu.name}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              FutureBuilder(
                future: getNote(lieu.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    print(snapshot.error.toString());
                    return Text("La note de ce lieu est indisponible");
                  } else {
                    final data = snapshot.data!;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "Ce lieu est noté $data",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 400,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: latLng, initialZoom: 12.0),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: latLng,
                          width: 180,
                          height: 60,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Tooltip(
                                      message:
                                          info?.toString() ??
                                          "Description non disponible",
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: Text(
                                          lieu.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.location_on),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  lieuProvider.changerLieu(lieu);
                  Navigator.pushNamed(context, "/comm");
                },
                icon: const Icon(Icons.rate_review),
                label: const Text("Noter et commenter ce lieu"),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Les commentaires",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent.shade100),
                      ),
                      child: FutureBuilder<List<Commentaire>>(
                        future: getComments(lieu.id!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Erreur lors du chargement des commentaires : ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Aucun commentaire pour ce lieu',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            );
                          } else {
                            final commentaires = snapshot.data!;
                            return ListView.separated(
                              shrinkWrap: true, // pour SingleChildScrollView
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: commentaires.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final c = commentaires[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  tileColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  title: Text(
                                    c.contenu,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  leading: const Icon(
                                    Icons.comment,
                                    color: Colors.blueAccent,
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
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

import 'package:explorez_votre_ville/models/api_cals.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:explorez_votre_ville/listeners/lieu_provider.dart';

class PlacesListView extends StatelessWidget {
  final List<Lieu> favoris;

  const PlacesListView({super.key, required this.favoris});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: favoris.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final lieu = favoris[index];

        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(lieu.name),
            trailing: Consumer<LieuProvider>(
              builder: (context, lieuProvider, child) {
                return ElevatedButton.icon(
                  onPressed: () {
                    lieuProvider.changerLieu(lieu);
                    Navigator.pushNamed(context, "/details");
                  },
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text("Voir"),
                );
              },
            ),
          ),
        );
      },
    );
  }
}


/* SizedBox(
            width: 160,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      lieu.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder<String>(
                          future: getImage(lieu.lat, lieu.lon),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            } else if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data == "404") {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            } else {
                              return Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer<LieuProvider>(
                      builder: (context, lieuProvider, child) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            lieuProvider.changerLieu(lieu);
                            Navigator.pushNamed(context, "/details");
                          },
                          icon: const Icon(Icons.search, size: 16),
                          label: const Text("Voir"),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ); */
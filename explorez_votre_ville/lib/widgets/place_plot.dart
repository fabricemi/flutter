import 'package:explorez_votre_ville/db/db.dart';
import 'package:explorez_votre_ville/listeners/lieu_provider.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class PlacePlot extends StatelessWidget {
  final Lieu e;
  final bool isFavoris;

  final void Function(Lieu lieu, bool isFav)? onTap;
  PlacePlot({super.key, required this.isFavoris, required this.e, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(e.lat, e.lon),
          width: 180,
          height: 60,
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: "Cliquer pour ajouter ou voir details",
                      child: ElevatedButton(
                        onPressed: () {
                          if (onTap != null) {
                            onTap!(e, isFavoris);
                          }
                        },
                        child: Text(
                          e.name,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.location_on, color: Colors.blue, size: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

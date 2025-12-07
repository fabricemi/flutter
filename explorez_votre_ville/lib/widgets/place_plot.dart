import 'package:explorez_votre_ville/db/db.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlacePlot extends StatelessWidget {
  final Lieu e;
  const PlacePlot({super.key, required this.e});

  void _insert() async {
    print("debut");

    await inserLieu(e);
    await getCities();
    await getLieux(e.city);
    print("fin");
  }

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
                    child: ElevatedButton(
                      onPressed: () {
                        _insert();
                      },
                      child: Text(
                        e.name,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

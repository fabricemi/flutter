import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:explorez_votre_ville/models/api_cals.dart';
import 'package:explorez_votre_ville/models/lieu.dart';

class RechercheProviders with ChangeNotifier {
  List<Lieu> _futurListLieuxTrouve = [];

  List<Lieu> get futurListLieuxTrouve => _futurListLieuxTrouve;

  void getResulat(String nom, LatLng latLng, String city) async {
    _futurListLieuxTrouve = await getPlaceByName(
      nom,
      latLng.latitude,
      latLng.longitude,
      city,
    );
    notifyListeners();
  }
}

import 'dart:convert';

import 'package:explorez_votre_ville/models/meteo.dart';
import 'package:http/http.dart' as http;

const String API_KEY = "f435f9505d2966017395d02673666b05";

///retouner les données meteorogique d'un lieu genere une erreur sinon
Future<Meteo> fetchCityInfoFromOWM(String city) async {
  if (city.isEmpty) {
    throw Exception("une erreur s'est produite lors de la recuperation");
  }
  final response = await http.get(
    Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$API_KEY&units=metric&lang=fr",
    ),
    headers: {'User-Agent': 'FlutterApp', 'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    final bodyJson = jsonDecode(response.body);
    return Meteo.fromJson(bodyJson);
  } else {
    throw Exception("une erreur s'est produite lors de la recuperation");
  }
}

/// Récupérer les coordonnées d'un lieu ville (un couple [lat, long])
Future<List<double>> getCoordinates(String city) async {
  if (city.isEmpty) {
    throw Exception("une erreur s'est produite lors de la recuperation");
  }

  final response = await http.get(
    Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$API_KEY&units=metric&lang=fr",
    ),
    headers: {'User-Agent': 'FlutterApp', 'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    final bodyJson = jsonDecode(response.body);

    return [
      Meteo.fromJson(bodyJson).coords.lat,
      Meteo.fromJson(bodyJson).coords.lon,
    ];
  } else {
    throw Exception("une erreur s'est produite");
  }
}

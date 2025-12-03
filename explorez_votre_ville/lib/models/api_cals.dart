import 'dart:convert';

import 'package:explorez_votre_ville/models/lieu.dart';
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
Future<List<Lieu>> getCityPlaces(Meteo city) async {
  const GEO_API = "5b389f1f140a46118a29391272e46c13";
  print("appelé");

  final url =
      "https://api.geoapify.com/v2/places?categories=entertainment.museum&filter=circle:${city.coords.lon},${city.coords.lat},4000&apiKey=$GEO_API";

  final response = await http.get(
    Uri.parse(url),
    headers: {'User-Agent': 'FlutterApp'},
  );
  if (response.statusCode == 200) {
    List<Map<String, dynamic>> bodyJson = List<Map<String, dynamic>>.from(
      (jsonDecode(response.body)["features"] as List<dynamic>).map(
        (e) => e as Map<String, dynamic>,
      ),
    );
    List<Lieu> lieux = [];

    for (var e in bodyJson) {
      lieux.add(Lieu.fromJson(e["properties"]));
    }
    //print("ville ${city.city}");
    //print("coord: ${city.coords.lat} - ${city.coords.lon}");
    //print("cle api : $GEO_API");
    print("lieux= $lieux");
    //print("lieux= $bodyJson");
    return lieux;
  } else {
    throw Exception("une erreur s'est produite");
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

Future<Meteo> getCityWithCoordonates(double lat, double lon) async {
  final response = await http.get(
    Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=f435f9505d2966017395d02673666b05&units=metric&lang=fr",
    ),
    headers: {'User-Agent': 'FlutterApp', 'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    final bodyJson = jsonDecode(response.body);

    return Meteo.fromJson(bodyJson);
  } else {
    throw Exception("une erreur s'est produite");
  }
}

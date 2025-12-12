import 'dart:async';
import 'dart:convert';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/models/meteo.dart';
import 'package:http/http.dart' as http;

const String API_KEY = "f435f9505d2966017395d02673666b05";
const String googleApiKey = "AIzaSyCSfro1hT2VYMESdW-7VKo2_KJzWhwHmdg";

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
    print("donnée brut $bodyJson");
    return Meteo.fromJson(bodyJson);
  } else {
    throw Exception("une erreur s'est produite lors de la recuperation");
  }
}

/// Récupérer les coordonnées d'un lieu ville (un couple [lat, long])
Future<List<Lieu>> getCityPlaces(double lat, double lon) async {
  const GEO_API = "5b389f1f140a46118a29391272e46c13";
  print("appelé");

  final url =
      "https://api.geoapify.com/v2/places?categories=entertainment.museum&filter=circle:${lon},${lat},4000&apiKey=$GEO_API";

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
      lieux.add(Lieu.fromJson(e["properties"], lat, lon));
    }
    //print("ville ${city.city}");
    //print("coord: ${city.coords.lat} - ${city.coords.lon}");
    //print("cle api : $GEO_API");
    //print("lieux= $lieux");
    //print("lieux= $bodyJson");
    return lieux;
  } else {
    throw Exception("une erreur s'est produite");
  }
}

/// Récupérer les coordonnées d'un lieu ville (un couple [lat, long])
Future<List<Lieu>> getCityPlacesAvecCategorie(
  double lat,
  double lon,
  String categories, {
  String? ville,
}) async {
  const GEO_API = "5b389f1f140a46118a29391272e46c13";

  final url =
      "https://api.geoapify.com/v2/places?categories=$categories&filter=circle:${lon},${lat},10000&apiKey=$GEO_API";

  print("url= $url");

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'FlutterApp'},
    );

    if (response.statusCode != 200) {
      return [];
    }

    List<Map<String, dynamic>> bodyJson = List<Map<String, dynamic>>.from(
      (jsonDecode(response.body)["features"] as List<dynamic>).map(
        (e) => e as Map<String, dynamic>,
      ),
    );

    List<Lieu> lieux = [];

    for (var e in bodyJson) {
      try {
        lieux.add(
          ville != null
              ? Lieu.fromJson(e["properties"], lat, lon, ville: ville)
              : Lieu.fromJson(e["properties"], lat, lon),
        );
      } catch (err) {
        return [];
      }
    }

    //print("donnees brut lieux= $bodyJson");
    return lieux;
  } catch (e) {
    return [];
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

Future<List<Lieu>> getPlaceByName(
  String name,
  double lat,
  double lon,
  String ville,
) async {
  final query = Uri.encodeComponent("$name $ville");
  const apiKey = "5b389f1f140a46118a29391272e46c13";

  final url =
      "https://api.geoapify.com/v1/geocode/search?text=$query&bias=proximity:$lon,$lat&limit=1&apiKey=$apiKey";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    print("url ... $url");
    final features = (jsonDecode(response.body)["features"] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>();

    //print("feautures $features");

    if (features == null || features.isEmpty) {
      //print("Aucun lieu trouvé pour $name");
      return [];
    }
    List<Lieu> lieux = [];
    for (var e in features) {
      final coordLat = e["lat"] ?? lat;
      final coordLon = e["lon"] ?? lon;
      lieux.add(
        Lieu.fromJson(e["properties"], coordLat, coordLon, ville: ville),
      );
    }
    print("props $lieux");
    //print("Lieu trouvé : ${lieu.name} - ${lieu.city}");
    return lieux;
  } else {
    return [];
  }
}

Future<String?> getStreetViewImageUrl(
  String placeName, {
  double? lat,
  double? lon,
}) async {
  try {
    final query = Uri.encodeComponent(placeName);

    String geoUrl =
        "https://api.geoapify.com/v1/geocode/search?text=$query&limit=1&apiKey=$API_KEY";

    final geoResponse = await http.get(Uri.parse(geoUrl));

    if (geoResponse.statusCode != 200) return null;

    final geoJson = jsonDecode(geoResponse.body);
    final features = geoJson['features'] as List<dynamic>?;
    if (features == null || features.isEmpty) return null;

    final props = features.first['properties'] as Map<String, dynamic>;
    final double finalLat = lat ?? (props['lat'] as double? ?? 0);
    final double finalLon = lon ?? (props['lon'] as double? ?? 0);

    String streetViewUrl =
        "https://maps.googleapis.com/maps/api/streetview?size=600x400&location=$finalLat,$finalLon&key=$googleApiKey";

    return streetViewUrl;
  } catch (e) {
    return null;
  }
}

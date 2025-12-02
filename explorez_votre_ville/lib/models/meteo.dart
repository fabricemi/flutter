class TempNumData {
  final double temp;
  final double feelsLike;
  final int pressure;
  final int humidity;
  final double tempMin;
  final double tempMax;
  final double vitesse;
  //"wind": { "speed": 4.12, "deg": 240 }

  TempNumData({
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.tempMin,
    required this.tempMax,
    required this.vitesse,
  });

  factory TempNumData.fromJson(Map<String, dynamic> json) {
    double wind =
        double.tryParse(json["wind"]?["speed"]?.toString() ?? "0") ?? 0;

    return TempNumData(
      temp: json["temp"],
      feelsLike: json["feels_like"],
      pressure: json["pressure"],
      humidity: json["humidity"],
      tempMin: json["temp_min"],
      tempMax: json["temp_max"],
      vitesse: wind,
    );
  }
}

class TempCarData {
  final String main;
  final String description;
  final String icon;

  TempCarData({
    required this.main,
    required this.description,
    required this.icon,
  });

  factory TempCarData.fromJson(Map<String, dynamic> json) {
    return TempCarData(
      main: json["main"],
      description: json["description"],
      icon: json["icon"],
    );
  }
}

class Coords {
  final double lon;
  final double lat;
  Coords({required this.lon, required this.lat});

  factory Coords.fromJson(Map<String, dynamic> json) {
    return Coords(lon: json["lon"], lat: json["lat"]);
  }
}

class Meteo {
  final int id;
  final TempNumData tempNumData;
  final TempCarData tempCarData;
  final Coords coords;
  final String city;

  Meteo({
    required this.id,
    required this.tempNumData,
    required this.tempCarData,
    required this.coords,
    required this.city,
  });

  factory Meteo.fromJson(Map<String, dynamic> json) {
    final weatherJson = json["weather"] as List<dynamic>;
    final weatherList = weatherJson
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return Meteo(
      id: json["id"],
      tempNumData: TempNumData.fromJson(json["main"]),
      tempCarData: TempCarData.fromJson(weatherList.first),
      coords: Coords.fromJson(json["coord"]),
      city: json["name"],
    );
  }
}

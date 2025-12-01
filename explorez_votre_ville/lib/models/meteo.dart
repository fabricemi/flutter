class TempNumData {
  final double temp;
  final double feelsLike;
  final int pressure;
  final int humidity;

  TempNumData({
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
  });

  factory TempNumData.fromJson(Map<String, dynamic> json) {
    return TempNumData(
      temp: json["temp"],
      feelsLike: json["feels_like"],
      pressure: json["pressure"],
      humidity: json["humidity"],
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

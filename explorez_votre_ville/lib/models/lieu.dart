class Lieu {
  int? id;
  final String name;
  final double lat;
  final double lon;
  final String city;

  Lieu({
    this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.city,
  });

  factory Lieu.fromJson(Map<String, dynamic> json) {
    return Lieu(
      name: json["name"],
      lat: json["lat"],
      lon: json["lon"],
      city: json["city"],
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Lieu{name=$name - city=$city -lat=$lat - lon=$lon}";
  }

  Map<String, Object?> toMap() {
    return {"id": id, "name": name, "lat": lat, "lon": lon, "city": city};
  }
}

class City {
  final int id;
  final String name;
  final double lat;
  final double lon;

  City({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  String toString() {
    // TODO: implement toString
    return 'Favori{id: $id, city: $name}';
  }

  Map<String, Object?> toMap() {
    return {"name": name, "lat": lat, "lon": lon};
  }
}

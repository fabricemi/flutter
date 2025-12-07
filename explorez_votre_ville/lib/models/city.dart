class City {
  int? id;
  final String name;
  final double lat;
  final double lon;

  City({this.id, required this.name, required this.lat, required this.lon});

  @override
  String toString() {
    return 'Ville{id: $id, name: $name}';
  }

  Map<String, Object?> toMap() {
    return {"name": name, "lat": lat, "lon": lon};
  }
}

class Lieu {
  int? id;
  final String name;
  final double lat;
  final double lon;
  String city;
  double? cityLat;
  double? cityLon;

  Lieu({
    this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.city,
    this.cityLat,
    this.cityLon,
  });

  factory Lieu.fromJson(
    Map<String, dynamic> json,
    double lat,
    double lon, {
    String? lnom,
    String? ville,
  }) {
    String nom =
        lnom ??
        json["name"] ??
        json["address_line1"] ??
        json["street"] ??
        json["formatted"] ??
        "Lieu sans nom";

    String v = ville ?? json["city"];
    return Lieu(
      name: nom,
      lat: json["lat"],
      lon: json["lon"],
      city: v,
      cityLat: lat,
      cityLon: lon,
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

class LieuInfo {
  final String address;
  final String? phone;
  final String? openingHours;
  final bool? wheelchair;
  final bool? internetAccess;
  final String? website;

  LieuInfo({
    required this.address,
    this.phone,
    this.openingHours,
    this.wheelchair,
    this.internetAccess,
    this.website,
  });

  factory LieuInfo.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] ?? {};
    final contact = props['contact'] ?? {};
    final facilities = props['facilities'] ?? {};

    return LieuInfo(
      address: props['address_line2'] ?? '',
      phone: contact['phone'],
      openingHours: props['opening_hours'],
      wheelchair: facilities['wheelchair'],
      internetAccess: facilities['internet_access'],
      website: props['website'],
    );
  }

  @override
  String toString() {
    return '''
Adresse : $address
Téléphone : ${phone ?? 'N/A'}
Horaires : ${openingHours ?? 'N/A'}
Accès fauteuil : ${wheelchair == true ? 'Oui' : 'Non'}
Internet : ${internetAccess == true ? 'Oui' : 'Non'}
Site web : ${website ?? 'N/A'}
''';
  }
}

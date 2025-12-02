import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/models/meteo.dart';
import 'package:explorez_votre_ville/models/api_cals.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController(
    text: "Paris",
  );
  // Fonction appelée quand on tape une ville
  void _searchCity() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rechercher une ville")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Champ de recherche
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Entrez une ville (ex: Paris)",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _searchCity(),
              ),

              const SizedBox(height: 20),

              FutureBuilder(
                future: fetchCityInfoFromOWM(_controller.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    );
                  } else if (!snapshot.hasData) {
                    return Text('Aucune.');
                  } else {
                    Meteo meteo = snapshot.data!;
                    return _buildCityInfo(meteo);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildCityInfo(Meteo meteo) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        meteo.city,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
          letterSpacing: 1.2,
        ),
      ),
      SizedBox(height: 16),
      Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.teal.shade50,
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.cloud, color: Colors.teal, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Météo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    meteo.tempCarData.description,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.thermostat, color: Colors.teal, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Min / Max",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "${meteo.tempNumData.tempMin}° / ${meteo.tempNumData.tempMax}°",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.teal, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Humidité",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "${meteo.tempNumData.humidity}%",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.air, color: Colors.teal, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Pression",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "${meteo.tempNumData.pressure} hPa",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

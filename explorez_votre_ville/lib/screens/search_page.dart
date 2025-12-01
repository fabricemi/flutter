import 'package:flutter/material.dart';
import 'package:explorez_votre_ville/models/meteo.dart';
import 'package:explorez_votre_ville/models/api_cals.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Meteo? _meteo;        // Pour stocker les données météo
  bool _loading = false;
  String? _error;

  // Fonction appelée quand on tape une ville
  Future<void> _searchCity() async {
    final city = _controller.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await fetchCityInfoFromOWM(city);
      setState(() {
        _meteo = data;
      });
    } catch (e) {
      setState(() {
        _error = "Ville introuvable";
        _meteo = null;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rechercher une ville")),
      body: Padding(
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

            // Loader
            if (_loading) CircularProgressIndicator(),

            // Message d'erreur
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),

            // Affichage des résultats
            if (_meteo != null && !_loading)
              Expanded(child: _buildCityInfo(_meteo!)),
          ],
        ),
      ),
    );
  }

  /// Widget pour afficher les infos de la ville trouvée
  Widget _buildCityInfo(Meteo meteo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          meteo.city,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Affichage température principale
        Text(
          "${meteo.tempNumData.temp.round()}°C",
          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        ),

        Text(
          meteo.tempCarData.description.toUpperCase(),
          style: const TextStyle(fontSize: 20, color: Colors.grey),
        ),

        const SizedBox(height: 20),

        // Humidité et pression
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: [
              const Text("Humidité"),
              Text("${meteo.tempNumData.humidity}%"),
            ]),
            const SizedBox(width: 40),
            Column(children: [
              const Text("Pression"),
              Text("${meteo.tempNumData.pressure} hPa"),
            ]),
          ],
        ),
      ],
    );
  }
}

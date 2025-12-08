import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:explorez_votre_ville/db/db.dart';

class LieuFormPage extends StatefulWidget {
  final String city;

  const LieuFormPage({super.key, required this.city});

  @override
  State<LieuFormPage> createState() => _LieuFormPageState();
}

class _LieuFormPageState extends State<LieuFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lonCtrl = TextEditingController();

  LatLng? selectedPoint;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    super.dispose();
  }

  // Sélection sur carte
  Future<void> _selectOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapSelectPage(city: widget.city),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        selectedPoint = result;
        _latCtrl.text = result.latitude.toStringAsFixed(6);
        _lonCtrl.text = result.longitude.toStringAsFixed(6);
      });
    }
  }

  // Sauvegarde SQLite
  Future<void> _saveLieu() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_latCtrl.text.trim()) ?? 0.0;
    final lon = double.tryParse(_lonCtrl.text.trim()) ?? 0.0;

    final lieu = Lieu(
      id: null,
      name: _nameCtrl.text.trim(),
      lat: lat,
      lon: lon,
      city: widget.city,
      cityLat: lat,
      cityLon: lon,
    );

    await inserLieu(lieu);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lieu enregistré dans SQLite !")),
    );

    Navigator.pop(context, lieu);
  }

  //  Interface du formulaire
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un lieu à ${widget.city}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nom
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nom du lieu",
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? "Nom obligatoire" : null,
              ),
              const SizedBox(height: 20),

              // Latitude
              TextFormField(
                controller: _latCtrl,
                decoration: const InputDecoration(
                  labelText: "Latitude",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Longitude
              TextFormField(
                controller: _lonCtrl,
                decoration: const InputDecoration(
                  labelText: "Longitude",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Bouton carte
              ElevatedButton.icon(
                onPressed: _selectOnMap,
                icon: const Icon(Icons.map),
                label: const Text("Choisir sur la carte"),
              ),
              const SizedBox(height: 30),

              // Sauvegarde
              ElevatedButton.icon(
                onPressed: _saveLieu,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// PAGE DE SÉLECTION SUR CARTE
class MapSelectPage extends StatefulWidget {
  final String city;

  const MapSelectPage({super.key, required this.city});

  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  LatLng _center = LatLng(48.8566, 2.3522); // Paris par défaut
  LatLng? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sélectionner un point")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  _selected = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "explore_ville_app",
              ),

              // Marqueur rouge
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      child: const Icon(Icons.location_on,
                          size: 40, color: Colors.red),
                    ),
                  ],
                ),
            ],
          ),

          // Bouton "Valider"
          if (_selected != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selected),
                child: const Text("Valider ce point"),
              ),
            ),
        ],
      ),
    );
  }
}

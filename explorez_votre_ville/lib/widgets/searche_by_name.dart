import 'package:explorez_votre_ville/listeners/recherche_providers.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AddLieu extends StatelessWidget {
  final RechercheProviders provider;
  void Function(Lieu lieu)? onPressed;
  AddLieu({super.key, required this.provider, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: provider.futurListLieuxTrouve.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) {
        final l = provider.futurListLieuxTrouve[index];
        return ListTile(
          title: Text(l.name),
          subtitle: Text("${l.city}"),
          trailing: ElevatedButton.icon(
            onPressed: () {
              if (onPressed != null) {
                return onPressed!(l);
              }
            },
            label: Text("Ajouter aux favoris"),
          ),
        );
      },
    );
  }
}

class AddLieuComplted extends StatelessWidget {
  final void Function(Lieu lieu)? onAddLieuCalled;
  final String city;
  final LatLng latLng;
  final TextEditingController _controller2 = TextEditingController();

  AddLieuComplted({
    super.key,
    required this.city,
    required this.latLng,
    required this.onAddLieuCalled,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RechercheProviders(),
      child: Consumer<RechercheProviders>(
        builder: (context, provider, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller2,
                decoration: InputDecoration(
                  hintText: "Entrez un lieu (ex: Le Louvre)",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) {
                  provider.getResulat(value, latLng, city);
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 300,
                child: provider.futurListLieuxTrouve.isEmpty
                    ? const Center(child: Text("Aucun lieu trouvé."))
                    : AddLieu(
                        provider: provider,
                        onPressed: (lieu) {
                          if (onAddLieuCalled != null) {
                            return onAddLieuCalled!(lieu);
                          }
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';

class PlacesListView extends StatelessWidget {
  final List<Lieu> favoris;

  const PlacesListView({super.key, required this.favoris});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final lieu = favoris[index];
          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lieu.name),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.search),
                  label: Text("Voir"),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 10),
        itemCount: favoris.length,
      ),
    );
  }
}

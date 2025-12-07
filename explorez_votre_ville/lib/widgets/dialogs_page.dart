import 'package:explorez_votre_ville/utils/utils.dart';
import 'package:flutter/material.dart';

Future<String?> showCategoriesDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          height: 300,
          child: FutureBuilder<Map<String, String>>(
            future: getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucune catégorie'));
              }
              final entries = snapshot.data!.entries.toList();

              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: entries.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final key = entries[index].key;
                  final value = entries[index].value;
                  return ListTile(
                    title: Text(value),
                    onTap: () {
                      Navigator.pop(context, key);
                    },
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}

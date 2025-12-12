import 'package:explorez_votre_ville/db/intermediaires.dart';
import 'package:explorez_votre_ville/listeners/lieu_provider.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class CommenterEtNoter extends StatefulWidget {
  const CommenterEtNoter({super.key});

  @override
  State<CommenterEtNoter> createState() => _CommenterEtNoterState();
}

class _CommenterEtNoterState extends State<CommenterEtNoter> {
  late int _currentValue;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentValue = 1;
  }

  void _insertComment(String contenu, Lieu lieu) async {
    if (contenu.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saisir un commentaire')));
      return;
    }
    try {
      await ajouterUnCommentaire(lieu, contenu, _currentValue);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire ajouté avec succès')),
      );
      setState(() {
        _controller.clear();
        _currentValue = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'insertion : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Consumer<LieuProvider>(
          builder: (context, value, child) {
            Lieu? lieu = value.lieu;
            if (lieu == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Aucun lieu sélectionné"),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Retour à la recherche"),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Commenter et Noter : ${lieu.name}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    minLines: 5,
                    maxLines: 10,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      hintText: "Écrivez votre commentaire ici...",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Note : $_currentValue",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_currentValue > 1) {
                            setState(() => _currentValue--);
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_currentValue',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_currentValue < 10) {
                            setState(() => _currentValue++);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _insertComment(_controller.text, lieu),
                    icon: const Icon(Icons.send),
                    label: const Text("Valider"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

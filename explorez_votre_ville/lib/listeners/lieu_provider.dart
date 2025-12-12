import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:flutter/material.dart';

class LieuProvider with ChangeNotifier {
  Lieu? _lieu;
  Lieu? get lieu => _lieu!;

  void changerLieu(Lieu l) {
    _lieu = l;
    notifyListeners();
  }
}

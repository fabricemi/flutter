import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:explorez_votre_ville/models/api_cals.dart';
import 'package:explorez_votre_ville/models/lieu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RechercheProviders with ChangeNotifier {
  List<Lieu> _futurListLieuxTrouve = [];

  static const String _favoriteCityKey = 'favorite_city';
  static const String _recentSearchesKey = 'recent_searches';

  String? _favoriteCity;
  List<String> _recentSearches = [];

  List<Lieu> get futurListLieuxTrouve => _futurListLieuxTrouve;
  String? get favoriteCity => _favoriteCity;
  List<String> get recentSearches => _recentSearches;

  void getResulat(String nom, LatLng latLng, String city) async {
    _futurListLieuxTrouve = await getPlaceByName(
      nom,
      latLng.latitude,
      latLng.longitude,
      city,
    );
    notifyListeners();
  }

  Future<void> setFavoriteCity(String city) async {
    _favoriteCity = city;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoriteCityKey, city);
    notifyListeners();
  }

  Future<void> loadFavoriteCity() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteCity = prefs.getString(_favoriteCityKey);
    notifyListeners();
  }

  Future<void> addRecentSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recentSearchesKey) ?? [];

    if (!list.contains(city)) {
      list.insert(0, city);
    }

    _recentSearches = list.take(5).toList();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);

    notifyListeners();
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    notifyListeners();
  }
}

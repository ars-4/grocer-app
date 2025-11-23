import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKey = 'user_favorites_ids';

  static Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesStringList = prefs.getStringList(
      _favoritesKey,
    );

    if (favoritesStringList == null) {
      return {};
    }
    return favoritesStringList
        .map((idString) => int.tryParse(idString))
        .where((id) => id != null)
        .cast<int>()
        .toSet();
  }

  static Future<void> _saveFavorites(Set<int> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesStringList = favoriteIds
        .map((id) => id.toString())
        .toList();
    await prefs.setStringList(_favoritesKey, favoritesStringList);
  }

  static Future<void> favourited(int productId) async {
    final currentFavorites = await loadFavorites();
    if (!currentFavorites.contains(productId)) {
      currentFavorites.add(productId);
      await _saveFavorites(currentFavorites);
    }
  }

  static Future<void> unfavourited(int productId) async {
    final currentFavorites = await loadFavorites();
    if (currentFavorites.contains(productId)) {
      currentFavorites.remove(productId);
      await _saveFavorites(currentFavorites);
    }
  }
}

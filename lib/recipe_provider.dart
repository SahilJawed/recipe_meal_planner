import 'package:flutter/material.dart';
import 'db_helper.dart';

class RecipeProvider with ChangeNotifier {
  List<Map<String, dynamic>> _recipes = [];

  List<Map<String, dynamic>> get recipes => _recipes;

  Future<void> loadRecipes() async {
    _recipes = await DatabaseHelper.instance.getRecipes();
    notifyListeners();
  }

  Future<void> addRecipe(Map<String, dynamic> recipe) async {
    await DatabaseHelper.instance.addRecipe(recipe);
    await loadRecipes();
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await DatabaseHelper.instance.updateFavorite(id, isFavorite ? 1 : 0);
    await loadRecipes();
  }
}

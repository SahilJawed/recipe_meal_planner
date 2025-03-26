import 'package:flutter/material.dart';
import 'db_helper.dart';

class RecipeProvider with ChangeNotifier {
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get favoriteRecipes =>
      _recipes.where((recipe) => recipe['isFavorite'] == 1).toList();

  RecipeProvider() {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading recipes...');
      _recipes = await DatabaseHelper.instance.getRecipes();
      print('Recipes loaded: $_recipes');
    } catch (e) {
      print('Error loading recipes: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecipe(Map<String, dynamic> recipe) async {
    try {
      print('Adding recipe: $recipe');
      await DatabaseHelper.instance.addRecipe(recipe);
      print('Recipe added successfully');
      await loadRecipes(); // Refresh the list after adding
    } catch (e) {
      print('Error adding recipe: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    try {
      print('Toggling favorite for id $id to $isFavorite');
      await DatabaseHelper.instance.updateFavorite(id, isFavorite ? 1 : 0);
      await loadRecipes(); // Refresh the list after toggling
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }
}

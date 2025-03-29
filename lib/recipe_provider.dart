import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'recipedetailscreen.dart';

class RecipeProvider with ChangeNotifier {
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  String? _error;
  int? _userId;
  String _selectedPreference = 'None'; // Default preference

  List<Map<String, dynamic>> get recipes => List.unmodifiable(_recipes);
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get favoriteRecipes =>
      _recipes.where((recipe) => recipe['isFavorite'] == 1).toList();
  String get selectedPreference => _selectedPreference;

  RecipeProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    print('Initialized with userId: $_userId');
    if (_userId != null) {
      await loadRecipes(); // Default load of all recipes when app initializes
    }
  }

  Future<void> loadRecipes() async {
    if (_isLoading || _userId == null) {
      print('Cannot load recipes: isLoading=$_isLoading, userId=$_userId');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading all recipes for userId: $_userId...');
      _recipes = await DatabaseHelper.instance.getRecipes(_userId!);
      print('Recipes loaded: ${_recipes.length} recipes');
    } catch (e) {
      print('Error loading recipes: $e');
      _error = 'Failed to load recipes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load recipes by selected dietary preference
  Future<void> loadRecipesByPreference(String preference) async {
    if (_isLoading || _userId == null) {
      print('Cannot load recipes: isLoading=$_isLoading, userId=$_userId');
      return;
    }

    _isLoading = true;
    _error = null;
    _selectedPreference = preference; // Set the preference to the selected one
    notifyListeners();

    try {
      print(
        'Loading recipes for userId: $_userId with preference: $preference...',
      );
      _recipes = await DatabaseHelper.instance.getRecipesByPreference(
        _userId!,
        preference,
      );
      print(
        'Recipes loaded: ${_recipes.length} recipes with preference $preference',
      );
    } catch (e) {
      print('Error loading recipes: $e');
      _error = 'Failed to load recipes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecipe(Map<String, dynamic> recipe) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('Adding recipe for userId $_userId: $recipe');
      await DatabaseHelper.instance.addRecipe(_userId!, recipe);
      print('Recipe added successfully');
    } catch (e) {
      print('Error adding recipe: $e');
      _error = 'Failed to add recipe: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      await loadRecipes(); // Move loadRecipes here, after isLoading is set to false
    }
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    try {
      print('Toggling favorite for id $id to $isFavorite');
      await DatabaseHelper.instance.updateFavorite(id, isFavorite ? 1 : 0);
      final index = _recipes.indexWhere((recipe) => recipe['id'] == id);
      if (index != -1) {
        _recipes[index] = Map.from(_recipes[index])
          ..['isFavorite'] = isFavorite ? 1 : 0;
        notifyListeners();
      } else {
        await loadRecipes();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      _error = 'Failed to update favorite: $e';
      await loadRecipes();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshAfterLogin(int userId) async {
    _userId = userId;
    print('Refreshing after login with userId: $_userId');
    await loadRecipes();
  }

  void clearData() {
    _userId = null;
    _recipes = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteRecipe(int id) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('Deleting recipe with id $id for userId $_userId');
      await DatabaseHelper.instance.deleteRecipe(id);
      print('Recipe deleted successfully');
    } catch (e) {
      print('Error deleting recipe: $e');
      _error = 'Failed to delete recipe: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      await loadRecipes(); // Also ensure loadRecipes is called after isLoading is false
    }
  }
}

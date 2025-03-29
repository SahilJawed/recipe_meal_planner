import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_meal_planner/app_drawer.dart';
import 'recipe_provider.dart';
import 'add_recipe_screen.dart';
import 'recipedetailscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPreference = 'None'; // ✅ Defined and initialized

  @override
  void initState() {
    super.initState();
    _loadUserPreference();
  }

  Future<void> _loadUserPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPreference = prefs.getString('mealPreference') ?? 'None';
    });
  }

  Future<void> _logout(BuildContext context) async {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.clearData();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Book"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (recipeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${recipeProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => recipeProvider.loadRecipes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ✅ Filter recipes based on user preference
          final filteredRecipes =
              recipeProvider.recipes.where((recipe) {
                return _selectedPreference == 'None' ||
                    (recipe['preference'] == _selectedPreference);
              }).toList();

          if (filteredRecipes.isEmpty) {
            return const Center(child: Text('No matching recipes found.'));
          }

          return ListView.builder(
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              return ListTile(
                title: Text(recipe['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ingredients: ${recipe['ingredients']}'),
                    Text('Steps: ${recipe['steps']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        recipe['isFavorite'] == 1
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: recipe['isFavorite'] == 1 ? Colors.red : null,
                      ),
                      onPressed: () {
                        recipeProvider.toggleFavorite(
                          recipe['id'],
                          recipe['isFavorite'] == 0,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Delete Recipe'),
                                content: const Text(
                                  'Are you sure you want to delete this recipe?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await recipeProvider.deleteRecipe(recipe['id']);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

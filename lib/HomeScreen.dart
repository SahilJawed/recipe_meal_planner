import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_meal_planner/app_drawer.dart';
import 'recipe_provider.dart';
import 'add_recipe_screen.dart';
import 'recipedetailscreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          if (recipeProvider.recipes.isEmpty) {
            return const Center(child: Text('No recipes yet. Add one!'));
          }

          return ListView.builder(
            itemCount: recipeProvider.recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipeProvider.recipes[index];
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

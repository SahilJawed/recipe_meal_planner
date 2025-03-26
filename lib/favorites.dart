import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Recipes')),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (recipeProvider.error != null) {
            return Center(child: Text('Error: ${recipeProvider.error}'));
          }

          final favorites = recipeProvider.favoriteRecipes;
          if (favorites.isEmpty) {
            return const Center(child: Text('No favorite recipes yet.'));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final recipe = favorites[index];
              return ListTile(
                title: Text(recipe['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ingredients: ${recipe['ingredients']}'),
                    Text('Steps: ${recipe['steps']}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    recipeProvider.toggleFavorite(recipe['id'], false);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

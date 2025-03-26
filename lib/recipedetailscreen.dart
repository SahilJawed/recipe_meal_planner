import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title']),
        actions: [
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
              // Update the UI without navigating back
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(recipe['ingredients']),
              const SizedBox(height: 16),
              Text('Steps', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(recipe['steps']),
            ],
          ),
        ),
      ),
    );
  }
}

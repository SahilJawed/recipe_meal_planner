import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_provider.dart';
import 'add_recipe_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RecipeProvider()..loadRecipes(),
      child: RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Recipe Book")),
      body: ListView.builder(
        itemCount: recipeProvider.recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipeProvider.recipes[index];
          return ListTile(
            title: Text(recipe['title']),
            subtitle: Text(recipe['ingredients']),
            trailing: IconButton(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRecipeScreen()),
            ),
        child: Icon(Icons.add),
      ),
    );
  }
}

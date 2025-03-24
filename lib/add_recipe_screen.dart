import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Add Recipe")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(labelText: "Ingredients"),
            ),
            TextField(
              controller: _stepsController,
              decoration: InputDecoration(labelText: "Steps"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final recipe = {
                  'title': _titleController.text,
                  'ingredients': _ingredientsController.text,
                  'steps': _stepsController.text,
                  'isFavorite': 0,
                };
                recipeProvider.addRecipe(recipe);
                Navigator.pop(context);
              },
              child: Text("Add Recipe"),
            ),
          ],
        ),
      ),
    );
  }
}

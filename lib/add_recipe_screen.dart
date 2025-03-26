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
      appBar: AppBar(title: const Text("Add Recipe")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(labelText: "Ingredients"),
            ),
            TextField(
              controller: _stepsController,
              decoration: const InputDecoration(labelText: "Steps"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final ingredients = _ingredientsController.text.trim();
                final steps = _stepsController.text.trim();

                if (title.isEmpty || ingredients.isEmpty || steps.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                try {
                  final recipe = {
                    'title': title,
                    'ingredients': ingredients,
                    'steps': steps,
                    'isFavorite': 0,
                  };
                  await recipeProvider.addRecipe(recipe);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding recipe: $e')),
                  );
                }
              },
              child: const Text("Add Recipe"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }
}

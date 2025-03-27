import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  Future<void> _addRecipe() async {
    if (_formKey.currentState!.validate()) {
      final recipe = {
        'title': _titleController.text,
        'ingredients': _ingredientsController.text,
        'steps': _stepsController.text,
      };
      try {
        await Provider.of<RecipeProvider>(
          context,
          listen: false,
        ).addRecipe(recipe);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add recipe: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredients'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ingredients';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(labelText: 'Steps'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter steps';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addRecipe,
                child: const Text('Add Recipe'),
              ),
            ],
          ),
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

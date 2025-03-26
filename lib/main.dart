import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ThemeProvider.dart';
import 'recipe_provider.dart';
import 'add_recipe_screen.dart';
import 'settings.dart';
import 'favorites.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecipeProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDarkMode)),
      ],
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Recipe App',
          theme: themeProvider.currentTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recipe Book")),
      drawer: const AppDrawer(),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (recipeProvider.error != null) {
            return Center(child: Text('Error: ${recipeProvider.error}'));
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

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Text(
              'Recipe App',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

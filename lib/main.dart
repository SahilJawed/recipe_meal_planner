import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ThemeProvider.dart';
import 'recipe_provider.dart';
import 'add_recipe_screen.dart';
import 'settings.dart';
import 'favorites.dart';
import 'recipedetailscreen.dart';
import 'signin.dart'; // Add this import
import 'signup.dart'; // Add this import
import 'db_helper.dart'; // Add this import

// In main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Delete the database (for testing only)
  await DatabaseHelper.instance.deleteDatabaseFile();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecipeProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDarkMode)),
      ],
      child: RecipeApp(
        initialRoute: isLoggedIn ? const HomeScreen() : SigninPage(),
      ),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  final Widget initialRoute;

  const RecipeApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Recipe App',
          theme: themeProvider.currentTheme,
          home: initialRoute,
          routes: {
            '/home': (context) => const HomeScreen(),
            '/signin': (context) => SigninPage(),
            '/signup': (context) => SignupPage(),
          },
        );
      },
    );
  }
}

// Update HomeScreen to include logout functionality
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
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

// Update AppDrawer to include login state
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Center(
              child: Text(
                'Recipe App',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('Home', style: GoogleFonts.poppins(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text('Favorites', style: GoogleFonts.poppins(fontSize: 16)),
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
            title: Text('Settings', style: GoogleFonts.poppins(fontSize: 16)),
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

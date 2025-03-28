import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'recipe_provider.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dbHelper = DatabaseHelper.instance;
        final emailExists = await dbHelper.doesEmailExist(
          _emailController.text,
        );
        if (emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This email is already registered. Please use a different email.',
              ),
            ),
          );
          return;
        }

        final userId = await dbHelper.createUser(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', userId);

        final recipeProvider = Provider.of<RecipeProvider>(
          context,
          listen: false,
        );
        await recipeProvider.refreshAfterLogin(userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        String errorMessage = 'Failed to sign up. Please try again later.';
        if (e.toString().contains('UNIQUE constraint failed')) {
          errorMessage =
              'This email is already registered. Please use a different email.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? 'Please enter an email'
                              : (!value.contains('@'))
                              ? 'Please enter a valid email'
                              : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? 'Please enter a password'
                              : (value.length < 6)
                              ? 'Password must be at least 6 characters'
                              : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

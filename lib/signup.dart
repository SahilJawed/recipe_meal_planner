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

  // In SignupPage
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
        print('Set userId in SharedPreferences: $userId'); // Add this log

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
        print('Sign-up error: $e');
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
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _signup, child: const Text('Sign Up')),
            ],
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

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../database/db_helper.dart';
import '../models/user.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final DBHelper dbHelper = DBHelper();

  Future<void> signupUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    User user = User(name: name, email: email, password: password);

    final result = await dbHelper.registerUser(user);

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email already registered')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(user: user, onThemeChanged: (bool value) {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the primary background color from your app theme
    final Color appBackground = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign up to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    hintText: 'Username',
                    controller: nameController,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: 'Email',
                    controller: emailController,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: 'Password',
                    controller: passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(text: 'Sign Up', onPressed: signupUser),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

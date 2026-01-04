// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../database/db_helper.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    passwordController = TextEditingController(text: widget.user.password);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    User updatedUser = User(
      id: widget.user.id,
      name: name,
      email: email,
      password: password,
    );

    await dbHelper.updateUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );

    Navigator.pop(context, updatedUser); // Return updated user
  }

  @override
  Widget build(BuildContext context) {
    // Use the app theme for background and card colors
    final Color appBackground = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
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
                  // Avatar with initials
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      widget.user.name.isNotEmpty
                          ? widget.user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form fields
                  CustomTextField(hintText: 'Name', controller: nameController),
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

                  // Update Button
                  CustomButton(
                    text: 'Update Profile',
                    onPressed: updateProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

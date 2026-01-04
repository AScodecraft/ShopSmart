import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import '../database/db_helper.dart';
// import '../models/user.dart';

class SplashScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SplashScreen({super.key, required this.onThemeChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String themeKey = 'isDarkMode';

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _loadTheme();
    await _checkLoginStatus();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(themeKey) ?? false;
    widget.onThemeChanged(isDark);
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    if (userId != null) {
      final dbHelper = DBHelper();
      final user = await dbHelper.getUserById(userId);

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              user: user,
              onThemeChanged: widget.onThemeChanged, // ✅ now valid
            ),
          ),
        );
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(onThemeChanged: widget.onThemeChanged),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          Icon(Icons.shopping_cart, size: 90, color: colorScheme.onSurface),

          const SizedBox(height: 20),

          Text(
            'SmartShop',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),

          const SizedBox(height: 10),

          Text('Loading...', style: Theme.of(context).textTheme.bodyMedium),

          const Spacer(),
        ],
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/create_list_screen.dart';

void main() {
  runApp(const SmartShopApp());
}

class SmartShopApp extends StatefulWidget {
  const SmartShopApp({super.key});

  @override
  State<SmartShopApp> createState() => _SmartShopAppState();
}

class _SmartShopAppState extends State<SmartShopApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // 🔹 Load saved theme
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDarkMode') ?? false;

    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // 🔹 Toggle theme
  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);

    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartShop',

      // 🌤 LIGHT THEME (NEW COLOR SCHEME)
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color.fromARGB(
          255,
          255,
          248,
          248,
        ), // ✅ NEW: Very light pink background (instead of white)

        primaryColor: const Color.fromARGB(
          255,
          223,
          176,
          176,
        ), // Your main pink

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(
            255,
            223,
            176,
            176,
          ), // Main pink for AppBar
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: Colors.white, // Cards stay white for contrast
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(
              255,
              200,
              150,
              150,
            ), // Darker rose for buttons
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 200, 150, 150),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 223, 176, 176),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 223, 176, 176),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 200, 150, 150),
              width: 2,
            ),
          ),
        ),

        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 223, 176, 176),
          secondary: Color.fromARGB(255, 200, 150, 150),
          surface: Colors.white,
          background: Color.fromARGB(255, 255, 248, 248),
          error: Colors.red,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
        ),
      ),

      // 🌙 DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18),

        primaryColor: const Color.fromARGB(255, 223, 176, 176),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 28, 28, 28),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: const Color.fromARGB(255, 28, 28, 28),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 200, 150, 150),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 223, 176, 176),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 28, 28, 28),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 223, 176, 176),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 223, 176, 176),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 200, 150, 150),
              width: 2,
            ),
          ),
        ),

        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 223, 176, 176),
          secondary: Color.fromARGB(255, 200, 150, 150),
          surface: Color.fromARGB(255, 28, 28, 28),
          background: Color.fromARGB(255, 18, 18, 18),
          error: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
      ),

      themeMode: _themeMode,

      initialRoute: '/splash',

      routes: {
        '/splash': (context) => SplashScreen(onThemeChanged: toggleTheme),
        '/login': (context) => LoginScreen(onThemeChanged: toggleTheme),
        '/signup': (context) => const SignupScreen(),
        '/create-list': (context) => CreateListScreen(),
      },
    );
  }
}

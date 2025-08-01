import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  rosado,
  calipso,
  lavanda,
}

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.rosado: ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFB6C1), // Rosado más fuerte
      primary: const Color(0xFFFFB6C1),
      secondary: Colors.pinkAccent[100]!,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
  ),
  AppTheme.calipso: ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.tealAccent,
      primary: Colors.cyanAccent,
      secondary: Colors.tealAccent,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
  ),
  AppTheme.lavanda: ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFE6E6FA),
      primary: Color(0xFFE6E6FA),
      secondary: Colors.deepPurpleAccent,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
  ),
};

class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.rosado;

  AppTheme get currentTheme => _currentTheme;

  ThemeData get themeData => appThemeData[_currentTheme]!;

  ThemeProvider() {
    _loadTheme(); // Carga el tema guardado al iniciar
  }

  void changeTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme.name);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme');

    if (themeName != null) {
      _currentTheme = AppTheme.values.firstWhere(
            (e) => e.name == themeName,
        orElse: () => AppTheme.rosado,
      );
      notifyListeners();
    }
  }
}

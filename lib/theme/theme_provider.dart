import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  rosado,
  calipso,
  lavanda,
}

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.rosado: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFB6C1), // Rosado más fuerte
      primary: const Color(0xFFFFB6C1),
      secondary: Colors.pinkAccent[100]!,
    ),
    useMaterial3: true,
  ),
  AppTheme.calipso: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal[200]!,
      primary: Colors.cyan[100]!,
      secondary: Colors.teal[100]!,
    ),
    useMaterial3: true,
  ),
  AppTheme.lavanda: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE6E6FA),
      primary: const Color(0xFFE6E6FA),
      secondary: Colors.deepPurple[100]!,
    ),
    useMaterial3: true,
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

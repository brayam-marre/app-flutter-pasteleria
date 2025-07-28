import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedTheme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de Apariencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Elige una paleta de colores pastel',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Tarjetas de tema
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildThemeCard(
                  context,
                  themeProvider,
                  AppTheme.rosado,
                  'Rosado Pastel',
                  [Color(0xFFFFB6C1), Colors.white],
                  selectedTheme == AppTheme.rosado,
                ),
                _buildThemeCard(
                  context,
                  themeProvider,
                  AppTheme.calipso,
                  'Calipso Pastel',
                  [Colors.teal[100]!, Colors.cyan[100]!],
                  selectedTheme == AppTheme.calipso,
                ),
                _buildThemeCard(
                  context,
                  themeProvider,
                  AppTheme.lavanda,
                  'Lavanda Pastel',
                  [Color(0xFFE6E6FA), Colors.deepPurple[100]!],
                  selectedTheme == AppTheme.lavanda,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
      BuildContext context,
      ThemeProvider provider,
      AppTheme theme,
      String label,
      List<Color> colors,
      bool isSelected,
      ) {
    return GestureDetector(
      onTap: () => provider.changeTheme(theme),
      child: Container(
        width: 120,
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

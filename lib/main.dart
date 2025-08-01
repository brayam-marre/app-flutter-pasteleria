import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/ajustes_screen.dart';

import 'theme/theme_provider.dart';
import 'providers/unidad_provider.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UnidadProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const PasteleriaApp(),
    ),
  );
}

class PasteleriaApp extends StatelessWidget {
  const PasteleriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pastelería Dulce Tentación',
      theme: themeProvider.themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/ajustes': (context) => const AjustesScreen(),
      },
    );
  }
}

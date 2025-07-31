// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _usuarioActual;

  Map<String, dynamic>? get usuarioActual => _usuarioActual;

  /// Método para establecer el usuario después del login
  void login(Map<String, dynamic> usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }

  /// Cerrar sesión
  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }

  /// Verificar si hay sesión activa
  bool get estaAutenticado => _usuarioActual != null;
}

import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _usuarioActual;

  Map<String, dynamic>? get usuarioActual => _usuarioActual;

  /// Establecer usuario tras login
  void login(Map<String, dynamic> usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }

  /// Cerrar sesión
  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }

  /// Verifica si hay sesión activa
  bool get estaAutenticado => _usuarioActual != null;

  /// Obtener el rol actual
  String get rol => _usuarioActual?['rol'] ?? 'usuario';

  /// Obtener ID del usuario actual (útil para filtrar contenido por usuario)
  int? get idUsuario {
    final id = _usuarioActual?['id'];
    if (id == null) return null;
    return int.tryParse(id.toString());
  }
}

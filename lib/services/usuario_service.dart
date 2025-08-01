import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  final String apiUrl = 'https://dtentacion.es/api/usuarios.php';

  /// Login de usuario
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login': true,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] != null) return null;
      return data;
    } else {
      return null;
    }
  }

  /// Obtener lista de usuarios
  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  /// Crear un nuevo usuario
  Future<bool> crearUsuario(String username, String password, String rol, bool activo) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'rol': rol,
        'activo': activo ? 1 : 0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return !data.containsKey('error');
    } else {
      return false;
    }
  }

  /// Actualizar usuario (puede modificar contraseña, rol y/o estado activo)
  Future<bool> actualizarUsuario({
    required int id,
    String? password,
    String? rol,
    bool? activo,
  }) async {
    final Map<String, dynamic> body = {
      'id': id,
      if (password != null) 'password': password,
      if (rol != null) 'rol': rol,
      if (activo != null) 'activo': activo ? 1 : 0,
    };

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  /// Eliminar usuario por ID
  Future<bool> eliminarUsuario(int id) async {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'id=$id',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }
}

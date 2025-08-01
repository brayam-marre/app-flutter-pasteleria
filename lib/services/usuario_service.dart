import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  final String apiUrl = 'https://dtentacion.es/api/usuarios.php'; // cambia esto

  /// Login de usuario
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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
}

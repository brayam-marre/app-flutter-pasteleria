// archivo: lib/services/receta_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/receta.dart';
import '../models/receta_producto.dart';

class RecetaService {
  static const String baseUrl = 'https://dtentacion.es/api/recetas.php';

  Future<List<Receta>> obtenerRecetas(int idUsuario) async {
    final response = await http.get(Uri.parse('$baseUrl?idUsuario=$idUsuario'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Receta.fromMap(e)).toList();
    } else {
      throw Exception('Error al cargar recetas');
    }
  }

  Future<Receta> obtenerRecetaPorId(int recetaId) async {
    final response = await http.get(Uri.parse('$baseUrl?recetaId=$recetaId'));

    if (response.statusCode == 200) {
      return Receta.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener receta');
    }
  }

  Future<List<RecetaProducto>> obtenerProductosDeReceta(int recetaId) async {
    final response = await http.get(Uri.parse('$baseUrl?productosReceta=$recetaId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RecetaProducto.fromMap(e)).toList();
    } else {
      throw Exception('Error al cargar productos de receta');
    }
  }

  Future<int> insertarReceta(Receta receta, List<RecetaProducto> productos) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'receta': receta.toMap(),
        'productos': productos.map((e) => e.toMap()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['id'] ?? 0;
    } else {
      throw Exception('Error al insertar receta');
    }
  }

  Future<bool> actualizarReceta(Receta receta, List<RecetaProducto> productos) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'receta': receta.toMap(),
        'productos': productos.map((e) => e.toMap()).toList(),
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarReceta(int recetaId) async {
    final response = await http.delete(Uri.parse('$baseUrl?id=$recetaId'));
    return response.statusCode == 200;
  }
}

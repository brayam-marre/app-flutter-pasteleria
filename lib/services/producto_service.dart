// archivo: lib/services/producto_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ProductoService {
  static const String baseUrl = 'https://dtentacion.es/api/productos.php';

  /// Obtiene todos los productos de un usuario
  static Future<List<Producto>> obtenerProductos(int idUsuario) async {
    final response = await http.get(Uri.parse('$baseUrl?idUsuario=$idUsuario'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Producto.fromMap(e)).toList();
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  /// Inserta un nuevo producto
  static Future<bool> insertarProducto(Producto producto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toMap()),
    );

    print('Respuesta POST: ${response.statusCode}');
    print('Body: ${response.body}');

    return response.statusCode == 200;
  }

  /// Actualiza un producto existente
  static Future<bool> actualizarProducto(Producto producto) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toMap()),
    );
    return response.statusCode == 200;
  }

  /// Elimina un producto por ID
  static Future<bool> eliminarProducto(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl?id=$id'));
    return response.statusCode == 200;
  }
}

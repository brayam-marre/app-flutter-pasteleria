// lib/services/compra_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/compra.dart';
import '../models/compra_producto.dart';

class CompraService {
  static const String baseUrl = 'https://dtentacion.es/api/compras.php';

  /// Obtiene todas las compras de un usuario
  static Future<List<Compra>> obtenerCompras(int idUsuario) async {
    final response = await http.get(Uri.parse('$baseUrl?idUsuario=$idUsuario'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Compra.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener las compras');
    }
  }

  /// Obtiene los productos de una compra
  static Future<List<CompraProducto>> obtenerProductosDeCompra(int compraId) async {
    final response = await http.get(Uri.parse('$baseUrl?productosCompra=$compraId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CompraProducto.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener los productos de la compra');
    }
  }

  /// Inserta una nueva compra y sus productos
  static Future<int> insertarCompra(Compra compra, List<CompraProducto> productos) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'compra': compra.toMap(),
        'productos': productos.map((e) => e.toMap()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['id'] ?? 0;
    } else {
      throw Exception('Error al insertar la compra');
    }
  }

  /// Elimina una compra (si decides implementarlo en tu API)
  static Future<bool> eliminarCompra(int compraId) async {
    final response = await http.delete(Uri.parse('$baseUrl?id=$compraId'));
    return response.statusCode == 200;
  }
}

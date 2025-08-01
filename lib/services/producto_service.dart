import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ProductoService {
  static const String baseUrl = 'https://dtentacion.es/api/productos.php';

  Future<List<Producto>> obtenerProductos(int idUsuario) async {
    final response = await http.get(Uri.parse('$baseUrl?idUsuario=$idUsuario'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Producto.fromMap(e)).toList();
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<bool> insertarProducto(Producto producto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toMap()),
    );
    return response.statusCode == 200;
  }

  Future<bool> actualizarProducto(Producto producto) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toMap()),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarProducto(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl?id=$id'));
    return response.statusCode == 200;
  }
}

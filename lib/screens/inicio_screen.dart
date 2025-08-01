import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../screens/compras_screen.dart';
import '../screens/calculos_screen.dart';
import '../screens/productos_screen.dart';

import '../services/producto_service.dart';
import '../services/compra_service.dart';
import '../services/receta_service.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int cantidadProductos = 0;
  int cantidadCompras = 0;
  int cantidadRecetas = 0;
  int? idUsuario;

  @override
  void initState() {
    super.initState();
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuarioActual;
    idUsuario = usuario?['id'];
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    if (idUsuario == null) return;

    try {
      final productos = await ProductoService.obtenerProductos(idUsuario!);
      final compras = await CompraService.obtenerCompras(idUsuario!);
      final recetas = await RecetaService.obtenerRecetas(idUsuario!);

      setState(() {
        cantidadProductos = productos.length;
        cantidadCompras = compras.length;
        cantidadRecetas = recetas.length;
      });
    } catch (e) {
      print('Error al cargar estadísticas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<AuthProvider>(context).usuarioActual;
    final rawNombre = usuario?['username'] ?? 'usuario';
    final nombre = rawNombre[0].toUpperCase() + rawNombre.substring(1);

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/logo_pasteleria.png', height: 120)),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Bienvenida $nombre ❤️',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Productos', '$cantidadProductos', Icons.inventory_2, Colors.pink),
                _buildStatCard('Compras', '$cantidadCompras', Icons.shopping_cart, Colors.teal),
                _buildStatCard('Recetas', '$cantidadRecetas', Icons.receipt_long, Colors.deepPurple),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Accesos rápidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.0, // Más alargado
              children: [
                _buildAnimatedHomeCard(Icons.shopping_cart, 'Registrar Compra', () {
                  if (idUsuario != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ComprasScreen(idUsuario: idUsuario!)),
                    );
                  }
                }),
                _buildAnimatedHomeCard(Icons.calculate, 'Cálculos', () {
                  if (idUsuario != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CalculosScreen(idUsuario: idUsuario!)),
                    );
                  }
                }),
                _buildAnimatedHomeCard(Icons.inventory, 'Productos', () {
                  if (idUsuario != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductosScreen(idUsuario: idUsuario!)),
                    );
                  }
                }),
                _buildAnimatedHomeCard(Icons.settings, 'Ajustes', () {
                  Navigator.pushNamed(context, '/ajustes');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      width: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAnimatedHomeCard(IconData icon, String label, VoidCallback onTap) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 150),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: Colors.pink),
                    const SizedBox(height: 6),
                    Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

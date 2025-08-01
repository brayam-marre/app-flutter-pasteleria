import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../db/database_helper.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int cantidadProductos = 0;
  int cantidadCompras = 0;
  int cantidadRecetas = 0;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuarioActual;
    final idUsuario = usuario?['id'];
    if (idUsuario == null) return;

    final productos = await DatabaseHelper().obtenerProductos(idUsuario);
    final compras = await DatabaseHelper().obtenerCompras(idUsuario);
    final recetas = await DatabaseHelper().obtenerRecetas(idUsuario);

    setState(() {
      cantidadProductos = productos.length;
      cantidadCompras = compras.length;
      cantidadRecetas = recetas.length;
    });
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
            // 🖼️ Logo
            Center(
              child: Image.asset('assets/logo_pasteleria.png', height: 120),
            ),
            const SizedBox(height: 20),

            // 👋 Bienvenida
            Center(
              child: Text(
                'Bienvenida $nombre ❤️',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // 📊 Estadísticas dinámicas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Productos', '$cantidadProductos', context),
                _buildStatCard('Compras', '$cantidadCompras', context),
                _buildStatCard('Recetas', '$cantidadRecetas', context),
              ],
            ),
            const SizedBox(height: 24),

            // ⚡ Accesos rápidos
            const Text('Accesos rápidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
              children: [
                _buildHomeCard(Icons.shopping_cart, 'Registrar Compra', () {
                  Navigator.pushNamed(context, '/compras');
                }),
                _buildHomeCard(Icons.calculate, 'Cálculos', () {
                  Navigator.pushNamed(context, '/calculos');
                }),
                _buildHomeCard(Icons.inventory, 'Productos', () {
                  Navigator.pushNamed(context, '/productos');
                }),
                _buildHomeCard(Icons.settings, 'Ajustes', () {
                  Navigator.pushNamed(context, '/ajustes');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(title),
      ],
    );
  }

  Widget _buildHomeCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.pink),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

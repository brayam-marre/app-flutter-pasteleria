import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<AuthProvider>(context).usuarioActual;
    final nombre = usuario?['nombre'] ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Logo (opcional)
            Center(
              child: Image.asset(
                'assets/logo_pasteleria.png', // Asegúrate de tener esta imagen en assets
                height: 120,
              ),
            ),
            const SizedBox(height: 20),

            // 👋 Bienvenida
            Text(
              '¡Bienvenido, $nombre!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 📊 Estadísticas rápidas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Productos', '42', context),
                _buildStatCard('Compras', '15', context),
                _buildStatCard('Recetas', '8', context),
              ],
            ),
            const SizedBox(height: 24),

            // ⚡ Accesos rápidos
            const Text(
              'Accesos rápidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
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
              Icon(icon, size: 40, color: Colors.pink),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _onMenuSelected(BuildContext context, String opcion) {
    if (opcion == 'logout') {
      Navigator.pushReplacementNamed(context, '/');
    } else if (opcion == 'Ajustes') {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/ajustes');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccionaste: $opcion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: colorScheme.primary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: const Center(
                child: Text(
                  'Dulce Tentación 💕',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Inicio'),
              onTap: () => _onMenuSelected(context, 'Inicio'),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Pedidos'),
              onTap: () => _onMenuSelected(context, 'Pedidos'),
            ),
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Cálculos'),
              onTap: () => _onMenuSelected(context, 'Cálculos'),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('Compras'),
              onTap: () => _onMenuSelected(context, 'Compras'),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Ajustes'),
              onTap: () => _onMenuSelected(context, 'Ajustes'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () => _onMenuSelected(context, 'logout'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          '¡Bienvenida al panel de administración! 🎂',
          style: TextStyle(
            fontSize: 20,
            color: colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

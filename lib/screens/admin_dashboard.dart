import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'inicio_screen.dart';
import 'calculos_screen.dart';
import 'compras_screen.dart';
import 'productos_screen.dart';
import 'clientes_screen.dart';
import '../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    final idUsuario = Provider.of<AuthProvider>(context, listen: false).usuarioActual?['id'];
    _pantallas = [
      const InicioScreen(),
      CalculosScreen(idUsuario: idUsuario),
      ComprasScreen(idUsuario: idUsuario),
      ProductosScreen(idUsuario: idUsuario),
    ];
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onMenuSelected(String opcion) {
    switch (opcion) {
      case 'Clientes':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientesScreen()));
        break;
      case 'Ajustes':
        Navigator.pushNamed(context, '/ajustes');
        break;
      case 'Cerrar Sesión':
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final esAdmin = auth.usuarioActual?['rol'] == 'administrador';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pantallas[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Cálculos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Compras'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Productos'),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: _onMenuSelected,
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) => [
          if (esAdmin)
            const PopupMenuItem(value: 'Clientes', child: Text('Clientes')),
          if (esAdmin)
            const PopupMenuItem(value: 'Ajustes', child: Text('Ajustes')),
          const PopupMenuItem(value: 'Cerrar Sesión', child: Text('Cerrar sesión')),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

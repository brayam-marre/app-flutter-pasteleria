import 'package:flutter/material.dart';
import 'compras_screen.dart';
import 'productos_screen.dart';
import 'calculos_screen.dart';
import 'clientes_screen.dart';
import 'inicio_screen.dart'; // Pantalla blanca por ahora

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pantallas = [
    const InicioScreen(),
    const CalculosScreen(),
    const ComprasScreen(),
    const ProductosScreen(),
  ];

  final List<String> _titulos = [
    'Inicio',
    'Cálculos',
    'Compras',
    'Productos',
  ];

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(_titulos[_selectedIndex]),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Clientes', child: Text('Clientes')),
              PopupMenuItem(value: 'Ajustes', child: Text('Ajustes')),
              PopupMenuItem(value: 'Cerrar Sesión', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
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
    );
  }
}

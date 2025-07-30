import 'package:flutter/material.dart';
import '../models/receta.dart';
import '../models/receta_producto.dart';
import '../models/producto.dart';
import '../db/database_helper.dart';
import 'crear_receta_screen.dart';
import 'modificar_receta_screen.dart';

class CalculosScreen extends StatefulWidget {
  const CalculosScreen({super.key});

  @override
  State<CalculosScreen> createState() => _CalculosScreenState();
}

class _CalculosScreenState extends State<CalculosScreen> {
  List<Receta> recetas = [];
  List<Producto> inventario = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final data = await DatabaseHelper().obtenerRecetas();
    final productos = await DatabaseHelper().obtenerProductos();
    setState(() {
      recetas = data;
      inventario = productos;
    });
  }

  Future<void> _mostrarDetalleReceta(Receta receta) async {
    final productos = await DatabaseHelper().obtenerProductosDeReceta(receta.id!);
    final costoTotal = productos.fold(0.0, (sum, p) => sum + (p.cantidadUsada * p.costoUnitario));
    final costoPorPorcion = receta.porciones > 0 ? costoTotal / receta.porciones : 0.0;

    double porcentajeGanancia = receta.porcentajeGanancia ?? 0;
    double ganancia = costoTotal * (porcentajeGanancia / 100);
    double precioVentaTotal = costoTotal + ganancia;
    double precioPorPorcion = receta.porciones > 0 ? precioVentaTotal / receta.porciones : 0;

    final gananciaController = TextEditingController(text: porcentajeGanancia.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(receta.nombre),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Porciones: ${receta.porciones}'),
                const SizedBox(height: 10),
                TextField(
                  controller: gananciaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '% Ganancia'),
                  onChanged: (value) {
                    porcentajeGanancia = double.tryParse(value) ?? 0;
                    ganancia = costoTotal * (porcentajeGanancia / 100);
                    precioVentaTotal = costoTotal + ganancia;
                    precioPorPorcion = receta.porciones > 0 ? precioVentaTotal / receta.porciones : 0;
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 10),
                Text('Costo total: \$${costoTotal.round()}'),
                Text('Ganancia: ${porcentajeGanancia.toStringAsFixed(0)}% (\$${ganancia.round()})'),
                Text('Precio de venta total: \$${precioVentaTotal.round()}'),
                Text('Precio por porción: \$${precioPorPorcion.round()}'),
                const Divider(),
                const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...productos.map((p) => ListTile(
                  title: Text(p.nombreProducto),
                  subtitle: Text(
                      '${p.cantidadUsada} ${p.unidad} - \$${(p.cantidadUsada * p.costoUnitario).round()}'),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await DatabaseHelper().eliminarReceta(receta.id!);
                Navigator.pop(context);
                _cargarDatos();
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModificarRecetaScreen(recetaId: receta.id!),
                  ),
                );
                if (resultado == true) {
                  _cargarDatos();
                }
              },
              child: const Text('Modificar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _navegarACrearReceta() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CrearRecetaScreen()),
    );
    if (resultado == true) {
      _cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cálculos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarACrearReceta,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recetas.length,
        itemBuilder: (context, index) {
          final receta = recetas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(receta.nombre),
              subtitle: Text('Porciones: ${receta.porciones}'),
              onTap: () => _mostrarDetalleReceta(receta),
              trailing: const Icon(Icons.restaurant_menu),
            ),
          );
        },
      ),
    );
  }
}

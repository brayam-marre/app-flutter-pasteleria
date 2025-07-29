import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/receta.dart';
import '../models/receta_producto.dart';
import '../models/producto.dart';
import '../db/database_helper.dart';
import '../providers/unidad_provider.dart';

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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(receta.nombre),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Porciones: ${receta.porciones}'),
              Text('Costo total: \$${costoTotal.round()}'),
              Text('Costo por porción: \$${costoPorPorcion.round()}'),
              const Divider(),
              const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...productos.map((p) => ListTile(
                title: Text(p.nombreProducto),
                subtitle: Text('${p.cantidadUsada} ${p.unidad} - \$${p.costoUnitario.round()}'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFormularioReceta() {
    final nombreController = TextEditingController();
    final porcionesController = TextEditingController();
    final cantidadController = TextEditingController();
    final costoController = TextEditingController();
    final unidadController = TextEditingController();
    Producto? productoSeleccionado;
    List<RecetaProducto> productos = [];

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            double total = productos.fold(0.0, (sum, p) => sum + (p.cantidadUsada * p.costoUnitario));
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nueva Receta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre de la receta'),
                  ),
                  TextField(
                    controller: porcionesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Porciones'),
                  ),
                  const Divider(),
                  const Text('Agregar Producto'),
                  Autocomplete<Producto>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return inventario.where((p) =>
                          p.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (p) => p.nombre,
                    onSelected: (producto) {
                      productoSeleccionado = producto;
                      unidadController.text = producto.unidad;
                      costoController.text = producto.valor.toStringAsFixed(0);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Producto'),
                      );
                    },
                  ),
                  Consumer<UnidadProvider>(
                    builder: (context, unidadProvider, _) {
                      return DropdownButtonFormField<String>(
                        value: unidadController.text.isNotEmpty ? unidadController.text : null,
                        items: unidadProvider.unidades.map((u) {
                          return DropdownMenuItem<String>(
                            value: u.nombre,
                            child: Text(u.nombre),
                          );
                        }).toList(),
                        onChanged: (value) {
                          unidadController.text = value ?? '';
                        },
                        decoration: const InputDecoration(labelText: 'Unidad'),
                      );
                    },
                  ),
                  TextField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad usada'),
                  ),
                  TextField(
                    controller: costoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Costo unitario'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final cantidad = double.tryParse(cantidadController.text) ?? 0;
                      String unidadUsada = unidadController.text;
                      if (productoSeleccionado == null || cantidad <= 0 || unidadUsada.isEmpty) return;

                      double valorProducto = productoSeleccionado!.valor;
                      double cantidadOriginal = productoSeleccionado!.cantidad;
                      String unidadOriginal = productoSeleccionado!.unidad;
                      double costoUnitarioCalculado;

                      if (unidadOriginal == unidadUsada) {
                        costoUnitarioCalculado = valorProducto / cantidadOriginal;
                      } else if (unidadOriginal == 'Kilogramos' && unidadUsada == 'Gramos') {
                        costoUnitarioCalculado = valorProducto / 1000;
                      } else if (unidadOriginal == 'Gramos' && unidadUsada == 'Kilogramos') {
                        costoUnitarioCalculado = valorProducto * 1000;
                      } else if (unidadOriginal == 'Litros' && unidadUsada == 'Mililitros') {
                        costoUnitarioCalculado = valorProducto / 1000;
                      } else if (unidadOriginal == 'Mililitros' && unidadUsada == 'Litros') {
                        costoUnitarioCalculado = valorProducto * 1000;
                      } else {
                        costoUnitarioCalculado = valorProducto / cantidadOriginal;
                      }

                      setModalState(() {
                        productos.add(RecetaProducto(
                          idReceta: 0,
                          nombreProducto: productoSeleccionado!.nombre,
                          unidad: unidadUsada,
                          cantidadUsada: cantidad,
                          costoUnitario: costoUnitarioCalculado,
                        ));
                      });

                      cantidadController.clear();
                      costoController.clear();
                      unidadController.clear();
                      productoSeleccionado = null;
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar producto'),
                  ),
                  const Divider(),
                  ...productos.map((p) => ListTile(
                    title: Text(p.nombreProducto),
                    subtitle: Text('${p.cantidadUsada} ${p.unidad} - \$${(p.cantidadUsada * p.costoUnitario).round()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setModalState(() => productos.remove(p)),
                    ),
                  )),
                  const SizedBox(height: 10),
                  Text('Total: \$${total.round()}'),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final nombre = nombreController.text.trim();
                      final porciones = int.tryParse(porcionesController.text) ?? 1;
                      if (nombre.isEmpty || productos.isEmpty) return;

                      final receta = Receta(nombre: nombre, porciones: porciones);
                      final recetaId = await DatabaseHelper().insertarReceta(receta);
                      for (final p in productos) {
                        await DatabaseHelper().insertarProductoDeReceta(p.copyWith(idReceta: recetaId));
                      }

                      Navigator.pop(context);
                      _cargarDatos();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Receta'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cálculos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioReceta,
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

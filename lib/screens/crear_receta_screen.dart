// archivo: lib/screens/crear_receta_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../models/receta.dart';
import '../models/receta_producto.dart';
import '../db/database_helper.dart';
import '../providers/unidad_provider.dart';

class CrearRecetaScreen extends StatefulWidget {
  final int idUsuario; // ✅ Se agregó el campo requerido

  const CrearRecetaScreen({super.key, required this.idUsuario});

  @override
  State<CrearRecetaScreen> createState() => _CrearRecetaScreenState();
}

class _CrearRecetaScreenState extends State<CrearRecetaScreen> {
  final nombreController = TextEditingController();
  final porcionesController = TextEditingController();
  final gananciaController = TextEditingController();
  final cantidadController = TextEditingController();
  final costoController = TextEditingController();
  final unidadController = TextEditingController();
  final productoController = TextEditingController();

  Producto? productoSeleccionado;
  List<Producto> inventario = [];
  List<RecetaProducto> productos = [];

  @override
  void initState() {
    super.initState();
    cargarInventario();
  }

  Future<void> cargarInventario() async {
    final data = await DatabaseHelper().obtenerProductos(widget.idUsuario); // ✅ Filtrar por usuario
    setState(() {
      inventario = data;
    });
  }

  void guardarReceta() async {
    final nombre = nombreController.text.trim();
    final porciones = int.tryParse(porcionesController.text) ?? 1;
    final ganancia = double.tryParse(gananciaController.text) ?? 0;

    if (nombre.isEmpty || productos.isEmpty) return;

    final receta = Receta(
      nombre: nombre,
      porciones: porciones,
      porcentajeGanancia: ganancia,
      idUsuario: widget.idUsuario, // ✅ Asociar receta al usuario
    );

    final recetaId = await DatabaseHelper().insertarReceta(receta, widget.idUsuario);

    for (final p in productos) {
      await DatabaseHelper().insertarProductoDeReceta(p.copyWith(idReceta: recetaId));
    }

    Navigator.pop(context, true);
  }


@override
  Widget build(BuildContext context) {
    double total = productos.fold(0.0, (sum, p) => sum + (p.cantidadUsada * p.costoUnitario));
    double ganancia = double.tryParse(gananciaController.text) ?? 0;
    double totalConGanancia = total + (total * (ganancia / 100));
    double totalConIVA = totalConGanancia * 1.19;
    int porciones = int.tryParse(porcionesController.text) ?? 1;
    double precioPorPorcionConIVA = porciones > 0 ? totalConIVA / porciones : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Receta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre de la receta'),
            ),
            TextField(
              controller: porcionesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Porciones'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: gananciaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '% Ganancia'),
              onChanged: (_) => setState(() {}),
            ),
            const Divider(),
            const Text('Agregar Producto', style: TextStyle(fontWeight: FontWeight.bold)),
            Autocomplete<Producto>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return inventario.where((p) =>
                    p.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (p) => p.nombre,
              onSelected: (producto) {
                setState(() {
                  productoSeleccionado = producto;
                  unidadController.text = producto.unidad;
                  costoController.text = producto.valor.toStringAsFixed(0);
                  productoController.text = producto.nombre;
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                productoController.text = controller.text;
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
                    setState(() => unidadController.text = value ?? '');
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
                final unidadUsada = unidadController.text;
                if (productoSeleccionado == null || cantidad <= 0 || unidadUsada.isEmpty) return;

                double valor = productoSeleccionado!.valor;
                double cantidadOriginal = productoSeleccionado!.cantidad;
                String unidadOriginal = productoSeleccionado!.unidad;

                double costoUnitarioCalculado;
                if (unidadOriginal == unidadUsada) {
                  costoUnitarioCalculado = valor / cantidadOriginal;
                } else if (unidadOriginal == 'Kilogramos' && unidadUsada == 'Gramos') {
                  costoUnitarioCalculado = valor / 1000;
                } else if (unidadOriginal == 'Gramos' && unidadUsada == 'Kilogramos') {
                  costoUnitarioCalculado = valor * 1000;
                } else if (unidadOriginal == 'Litros' && unidadUsada == 'Mililitros') {
                  costoUnitarioCalculado = valor / 1000;
                } else if (unidadOriginal == 'Mililitros' && unidadUsada == 'Litros') {
                  costoUnitarioCalculado = valor * 1000;
                } else {
                  costoUnitarioCalculado = valor / cantidadOriginal;
                }

                setState(() {
                  productos.add(RecetaProducto(
                    idReceta: 0,
                    nombreProducto: productoSeleccionado!.nombre,
                    unidad: unidadUsada,
                    cantidadUsada: cantidad,
                    costoUnitario: costoUnitarioCalculado,
                  ));
                  productoSeleccionado = null;
                  productoController.clear();
                  cantidadController.clear();
                  costoController.clear();
                  unidadController.clear();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto'),
            ),
            const Divider(),
            ...productos.map((p) => ListTile(
              title: Text(p.nombreProducto),
              subtitle: Text(
                  '${p.cantidadUsada} ${p.unidad} - \$${(p.cantidadUsada * p.costoUnitario).round()}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => productos.remove(p)),
              ),
            )),
            const SizedBox(height: 10),
            Text('Total costo: \$${total.round()}'),
            Text('Con % de ganancia: \$${totalConGanancia.round()}'),
            Text('Con IVA (19%): \$${totalConIVA.round()}'),
            Text('Porción con IVA: \$${precioPorPorcionConIVA.round()}'),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: guardarReceta,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Receta'),
            )
          ],
        ),
      ),
    );
  }
}

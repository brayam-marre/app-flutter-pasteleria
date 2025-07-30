// archivo: lib/screens/modificar_receta_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/receta.dart';
import '../models/receta_producto.dart';
import '../models/producto.dart';
import '../db/database_helper.dart';
import '../providers/unidad_provider.dart';

class ModificarRecetaScreen extends StatefulWidget {
  final int recetaId;

  const ModificarRecetaScreen({super.key, required this.recetaId});

  @override
  State<ModificarRecetaScreen> createState() => _ModificarRecetaScreenState();
}

class _ModificarRecetaScreenState extends State<ModificarRecetaScreen> {
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
  Receta? recetaOriginal;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final receta = await DatabaseHelper().obtenerRecetaPorId(widget.recetaId);
    final productosReceta = await DatabaseHelper().obtenerProductosDeReceta(widget.recetaId);
    final inventarioData = await DatabaseHelper().obtenerProductos();

    setState(() {
      recetaOriginal = receta;
      productos = productosReceta;
      inventario = inventarioData;

      nombreController.text = receta?.nombre ?? '';
      porcionesController.text = receta?.porciones.toString() ?? '1';
      gananciaController.text = receta?.porcentajeGanancia.toString() ?? '0';
    });
  }

  Future<void> _guardarCambios() async {
    final nombre = nombreController.text.trim();
    final porciones = int.tryParse(porcionesController.text) ?? 1;
    final ganancia = double.tryParse(gananciaController.text) ?? 0;

    if (nombre.isEmpty || productos.isEmpty || recetaOriginal == null) return;

    final recetaModificada = Receta(
      id: recetaOriginal!.id,
      nombre: nombre,
      porciones: porciones,
      porcentajeGanancia: ganancia,
    );

    await DatabaseHelper().actualizarReceta(recetaModificada);
    await DatabaseHelper().eliminarProductosDeReceta(recetaModificada.id!);
    for (final p in productos) {
      await DatabaseHelper().insertarProductoDeReceta(p.copyWith(idReceta: recetaModificada.id));
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    double total = productos.fold(0.0, (sum, p) => sum + (p.cantidadUsada * p.costoUnitario));
    final ganancia = double.tryParse(gananciaController.text) ?? 0;
    final totalConGanancia = total + (total * (ganancia / 100));
    final conIVA = totalConGanancia * 1.19;
    final porciones = int.tryParse(porcionesController.text) ?? 1;
    final porcionConIVA = porciones > 0 ? conIVA / porciones : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Modificar Receta')),
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
                  productoController.text = producto.nombre;
                  unidadController.text = producto.unidad;
                  costoController.text = producto.valor.toStringAsFixed(0);
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: productoController,
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
                  onChanged: (value) => setState(() => unidadController.text = value ?? ''),
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

                final valor = productoSeleccionado!.valor;
                final cantidadOriginal = productoSeleccionado!.cantidad;
                final unidadOriginal = productoSeleccionado!.unidad;
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
                    idReceta: widget.recetaId,
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
            const SizedBox(height: 10),
            ...productos.map((p) => ListTile(
              title: Text(p.nombreProducto),
              subtitle: Text(
                  '${p.cantidadUsada} ${p.unidad} - \$${(p.cantidadUsada * p.costoUnitario).round()}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => productos.remove(p)),
              ),
            )),
            const Divider(),
            Text('Total costo: \$${total.round()}'),
            Text('Con ganancia: \$${totalConGanancia.round()}'),
            Text('Con IVA (19%): \$${conIVA.round()}'),
            Text('Porción con IVA: \$${porcionConIVA.round()}'),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _guardarCambios,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
            )
          ],
        ),
      ),
    );
  }
}

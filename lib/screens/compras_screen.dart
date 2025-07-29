import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/compra.dart';
import '../models/compra_producto.dart';
import '../db/database_helper.dart';
import '../providers/unidad_provider.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  List<Compra> compras = [];

  @override
  void initState() {
    super.initState();
    _cargarCompras();
  }

  Future<void> _cargarCompras() async {
    final data = await DatabaseHelper().obtenerCompras();
    setState(() => compras = data);
  }

  void _mostrarDetalleCompra(Compra compra) async {
    final productos = await DatabaseHelper().obtenerProductosDeCompra(compra.id!);

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalle de ${compra.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...productos.map((p) => ListTile(
              title: Text(p.nombreProducto),
              subtitle: Text('${p.peso} ${p.unidad} - \$${p.valor.toStringAsFixed(2)}'),
            )),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioNuevaCompra() {
    final nombreController = TextEditingController();
    final productoController = TextEditingController();
    final pesoController = TextEditingController();
    final valorController = TextEditingController();
    final unidadController = TextEditingController();
    List<CompraProducto> productos = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              double total = productos.fold(0.0, (s, p) => s + p.valor);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nueva Compra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre de la compra'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Agregar Producto'),
                    TextField(
                      controller: productoController,
                      decoration: const InputDecoration(labelText: 'Producto'),
                    ),
                    Consumer<UnidadProvider>(
                      builder: (context, unidadProvider, _) {
                        return DropdownButtonFormField<String>(
                          value: unidadProvider.unidades.isNotEmpty ? unidadProvider.unidades.first.nombre : null,
                          items: unidadProvider.unidades.map((u) {
                            return DropdownMenuItem<String>(
                              value: u.nombre,
                              child: Text(u.nombre),
                            );
                          }).toList(),
                          onChanged: (value) => unidadController.text = value ?? '',
                          decoration: const InputDecoration(labelText: 'Unidad'),
                        );
                      },
                    ),
                    TextField(
                      controller: pesoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Peso'),
                    ),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Valor \$'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        final producto = productoController.text.trim();
                        final unidad = unidadController.text.trim();
                        final peso = double.tryParse(pesoController.text) ?? 0;
                        final valor = double.tryParse(valorController.text) ?? 0;
                        if (producto.isEmpty || unidad.isEmpty || peso <= 0 || valor <= 0) return;

                        setModalState(() {
                          productos.add(CompraProducto(
                            idCompra: 0,
                            nombreProducto: producto,
                            unidad: unidad,
                            peso: peso,
                            valor: valor,
                          ));
                        });

                        productoController.clear();
                        pesoController.clear();
                        valorController.clear();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar producto'),
                    ),
                    const Divider(),
                    ...productos.map((p) => ListTile(
                      title: Text(p.nombreProducto),
                      subtitle: Text('${p.peso} ${p.unidad} - \$${p.valor.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setModalState(() => productos.remove(p)),
                      ),
                    )),
                    const SizedBox(height: 10),
                    Text('Total: \$${total.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final nombre = nombreController.text.trim();
                        if (nombre.isEmpty || productos.isEmpty) return;

                        final compra = Compra(
                          nombre: nombre,
                          fecha: DateTime.now().toIso8601String(),
                          total: total,
                        );
                        final compraId = await DatabaseHelper().insertarCompra(compra);

                        for (final p in productos) {
                          await DatabaseHelper().insertarProductoDeCompra(
                            p.copyWith(idCompra: compraId),
                          );
                        }

                        Navigator.pop(context);
                        _cargarCompras();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Compra'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioNuevaCompra,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: compras.length,
        itemBuilder: (context, index) {
          final compra = compras[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(compra.nombre),
              subtitle: Text(
                'Fecha: ${compra.fecha.substring(0, 10)}\nTotal: \$${compra.total.toStringAsFixed(2)}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.shopping_cart_outlined),
              onTap: () => _mostrarDetalleCompra(compra),
            ),
          );
        },
      ),
    );
  }
}

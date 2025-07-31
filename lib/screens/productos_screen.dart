import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../db/database_helper.dart';
import '../providers/unidad_provider.dart';

class ProductosScreen extends StatefulWidget {
  final int idUsuario;

  const ProductosScreen({super.key, required this.idUsuario});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final data = await DatabaseHelper().obtenerProductos(widget.idUsuario);
    setState(() => productos = data);
  }

  void _mostrarFormularioProducto({Producto? producto}) {
    final nombreController = TextEditingController(text: producto?.nombre ?? '');
    final pesoController = TextEditingController(text: producto?.cantidad.toString() ?? '');
    final valorController = TextEditingController(text: producto?.valor.toStringAsFixed(0) ?? '');
    final unidadController = TextEditingController(text: producto?.unidad ?? '');

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
          child: Consumer<UnidadProvider>(
            builder: (context, unidadProvider, _) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(producto == null ? 'Nuevo Producto' : 'Editar Producto',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: pesoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Peso'),
                    ),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Valor (CLP)'),
                    ),
                    DropdownButtonFormField<String>(
                      value: unidadProvider.unidades.any((u) => u.nombre == unidadController.text)
                          ? unidadController.text
                          : unidadProvider.unidades.isNotEmpty
                          ? unidadProvider.unidades.first.nombre
                          : null,
                      items: unidadProvider.unidades.map((u) {
                        return DropdownMenuItem(
                          value: u.nombre,
                          child: Text(u.nombre),
                        );
                      }).toList(),
                      onChanged: (value) => unidadController.text = value ?? '',
                      decoration: const InputDecoration(labelText: 'Unidad de medida'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      onPressed: () async {
                        final nombre = nombreController.text.trim();
                        final peso = double.tryParse(pesoController.text.trim()) ?? 0;
                        final valor = double.tryParse(valorController.text.trim()) ?? 0;
                        final unidad = unidadController.text.trim();

                        if (nombre.isEmpty || unidad.isEmpty || peso <= 0 || valor <= 0) return;

                        if (producto == null) {
                          await DatabaseHelper().insertarProducto(
                            Producto(
                              nombre: nombre,
                              unidad: unidad,
                              cantidad: peso,
                              valor: valor,
                              idUsuario: widget.idUsuario,
                            ),
                          );
                        } else {
                          await DatabaseHelper().actualizarProducto(
                            Producto(
                              id: producto.id,
                              nombre: nombre,
                              unidad: unidad,
                              cantidad: peso,
                              valor: valor,
                              idUsuario: widget.idUsuario,
                            ),
                          );
                        }

                        Navigator.pop(context);
                        _cargarProductos();
                      },
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

  Future<void> _eliminarProducto(int id) async {
    await DatabaseHelper().eliminarProducto(id);
    _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos / Insumos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioProducto(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final p = productos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('${p.nombre} - ${p.cantidad} ${p.unidad}'),
              subtitle: Text('Valor: \$${p.valor.round()}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _mostrarFormularioProducto(producto: p),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _eliminarProducto(p.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

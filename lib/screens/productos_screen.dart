import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
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
    try {
      final data = await ProductoService.obtenerProductos(widget.idUsuario);
      setState(() => productos = data);
    } catch (e) {
      // Mostrar error si la carga falla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar productos')),
      );
    }
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
              final unidades = unidadProvider.unidades;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      producto == null ? 'Nuevo Producto' : 'Editar Producto',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: pesoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                    ),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Valor (CLP)'),
                    ),
                    DropdownButtonFormField<String>(
                      value: unidades.any((u) => u.nombre == unidadController.text)
                          ? unidadController.text
                          : (unidades.isNotEmpty ? unidades.first.nombre : null),
                      items: unidades.map((u) {
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

                        final nuevoProducto = Producto(
                          id: producto?.id,
                          nombre: nombre,
                          unidad: unidad,
                          cantidad: peso,
                          valor: valor,
                          idUsuario: widget.idUsuario,
                        );

                        if (producto == null) {
                          await ProductoService.insertarProducto(nuevoProducto);
                        } else {
                          await ProductoService.actualizarProducto(nuevoProducto);
                        }

                        if (context.mounted) Navigator.pop(context);
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
    await ProductoService.eliminarProducto(id);
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
      body: productos.isEmpty
          ? const Center(child: Text('No hay productos registrados.'))
          : ListView.builder(
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../providers/unidad_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/usuarios_screen.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedTheme = themeProvider.currentTheme;
    final usuario = Provider.of<AuthProvider>(context).usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elige una paleta de colores pastel',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildThemeCard(
                    context,
                    themeProvider,
                    AppTheme.rosado,
                    'Rosado Pastel',
                    [const Color(0xFFFFB6C1), Colors.white],
                    selectedTheme == AppTheme.rosado,
                  ),
                  _buildThemeCard(
                    context,
                    themeProvider,
                    AppTheme.calipso,
                    'Calipso Pastel',
                    [Colors.teal[100]!, Colors.cyan[100]!],
                    selectedTheme == AppTheme.calipso,
                  ),
                  _buildThemeCard(
                    context,
                    themeProvider,
                    AppTheme.lavanda,
                    'Lavanda Pastel',
                    [const Color(0xFFE6E6FA), Colors.deepPurple[100]!],
                    selectedTheme == AppTheme.lavanda,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Unidades de Medida',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _abrirModalUnidades(context),
                icon: const Icon(Icons.settings),
                label: const Text("Gestionar Unidades"),
              ),
              const SizedBox(height: 30),

              // Mostrar solo si es administrador
              if (usuario?['rol'] == 'administrador') ...[
                const Divider(height: 32),
                const Text(
                  'Gestión de Usuarios',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.supervisor_account),
                  label: const Text('Administrar Usuarios'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UsuariosScreen()),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(
      BuildContext context,
      ThemeProvider provider,
      AppTheme theme,
      String label,
      List<Color> colors,
      bool isSelected,
      ) {
    return GestureDetector(
      onTap: () => provider.changeTheme(theme),
      child: Container(
        width: 120,
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _abrirModalUnidades(BuildContext context) {
    final unidadProvider = Provider.of<UnidadProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Consumer<UnidadProvider>(
                builder: (context, provider, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Unidades de Medida",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: provider.unidades.length,
                        itemBuilder: (context, index) {
                          final unidad = provider.unidades[index];
                          return ListTile(
                            title: Text(unidad.nombre),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    controller.text = unidad.nombre;
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Editar Unidad"),
                                        content: TextField(
                                          controller: controller,
                                          decoration: const InputDecoration(hintText: "Ej: Litros"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              final nuevoNombre = controller.text.trim();
                                              if (nuevoNombre.isNotEmpty) {
                                                provider.editarUnidad(index, nuevoNombre);
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Guardar"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => provider.eliminarUnidad(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(hintText: "Ej: Litros"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final nombre = controller.text.trim();
                            if (nombre.isNotEmpty) {
                              provider.agregarUnidad(nombre);
                              controller.clear();
                            }
                          },
                          child: const Text("Agregar"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

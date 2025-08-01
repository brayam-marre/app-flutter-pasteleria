import 'package:flutter/material.dart';
import '../services/usuario_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UsuarioService _usuarioService = UsuarioService();
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _usuariosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _searchController.addListener(_filtrarUsuarios);
  }

  Future<void> _cargarUsuarios() async {
    try {
      final usuarios = await _usuarioService.obtenerUsuarios();
      setState(() {
        _usuarios = usuarios;
        _usuariosFiltrados = usuarios;
      });
    } catch (e) {
      print('Error cargando usuarios: $e');
    }
  }

  void _filtrarUsuarios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _usuariosFiltrados = _usuarios.where((usuario) {
        final username = usuario['username'].toLowerCase();
        final rol = usuario['rol'].toLowerCase();
        return username.contains(query) || rol.contains(query);
      }).toList();
    });
  }

  void _mostrarFormulario({Map<String, dynamic>? usuario}) {
    final usernameController = TextEditingController(text: usuario?['username'] ?? '');
    final passwordController = TextEditingController();
    String rol = usuario?['rol'] ?? 'usuario';
    bool activo = usuario?['activo'] == 1 || usuario == null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(usuario == null ? 'Crear Usuario' : 'Editar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
              enabled: usuario == null,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña (opcional)'),
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              value: rol,
              onChanged: (value) => setState(() => rol = value!),
              items: const [
                DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
              ],
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
            Row(
              children: [
                const Text("Activo"),
                Switch(
                  value: activo,
                  onChanged: (val) => setState(() => activo = val),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (usuario == null) {
                // CREAR NUEVO USUARIO
                await _usuarioService.crearUsuario(
                  usernameController.text.trim(),
                  passwordController.text.trim(),
                  rol,
                  activo,
                );
              } else {
                // ACTUALIZAR
                await _usuarioService.actualizarUsuario(
                  id: usuario['id'],
                  password: passwordController.text.trim().isNotEmpty ? passwordController.text.trim() : null,
                  rol: rol,
                  activo: activo,
                );
              }
              Navigator.pop(context);
              _cargarUsuarios();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacion(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar usuario?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              await _usuarioService.eliminarUsuario(id);
              Navigator.pop(context);
              _cargarUsuarios();
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioTile(Map<String, dynamic> usuario) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(usuario['username']),
        subtitle: Text("Rol: ${usuario['rol']} • Último acceso: ${usuario['ultimo_login'] ?? 'N/A'}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _mostrarFormulario(usuario: usuario)),
            IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmarEliminacion(usuario['id'])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Usuarios")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Buscar por nombre o rol",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _usuariosFiltrados.isEmpty
                ? const Center(child: Text("No hay usuarios"))
                : ListView.builder(
              itemCount: _usuariosFiltrados.length,
              itemBuilder: (_, i) => _buildUsuarioTile(_usuariosFiltrados[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

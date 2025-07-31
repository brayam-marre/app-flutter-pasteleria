// models/usuario.dart
class Usuario {
  int? id;
  String username;
  String password;
  String rol;
  bool activo;
  String? ultimoLogin;

  Usuario({
    this.id,
    required this.username,
    required this.password,
    required this.rol,
    this.activo = true,
    this.ultimoLogin,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      rol: map['rol'],
      activo: map['activo'] == 1,
      ultimoLogin: map['ultimo_login'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'rol': rol,
      'activo': activo ? 1 : 0,
      'ultimo_login': ultimoLogin,
    };
  }
}

class Receta {
  int? id;
  String nombre;
  int porciones;
  double porcentajeGanancia;
  int? idUsuario; // 🔹 Nuevo campo

  Receta({
    this.id,
    required this.nombre,
    required this.porciones,
    this.porcentajeGanancia = 0.0,
    this.idUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'porciones': porciones,
      'porcentajeGanancia': porcentajeGanancia,
      'idUsuario': idUsuario, // 🔹 Incluido
    };
  }

  factory Receta.fromMap(Map<String, dynamic> map) {
    return Receta(
      id: map['id'],
      nombre: map['nombre'],
      porciones: map['porciones'],
      porcentajeGanancia: map['porcentajeGanancia']?.toDouble() ?? 0.0,
      idUsuario: map['idUsuario'], // 🔹 Lo recuperamos
    );
  }
}

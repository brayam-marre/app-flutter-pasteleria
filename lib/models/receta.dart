class Receta {
  int? id;
  String nombre;
  int porciones;
  double porcentajeGanancia;

  Receta({
    this.id,
    required this.nombre,
    required this.porciones,
    this.porcentajeGanancia = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'porciones': porciones,
      'porcentajeGanancia': porcentajeGanancia,
    };
  }

  factory Receta.fromMap(Map<String, dynamic> map) {
    return Receta(
      id: map['id'],
      nombre: map['nombre'],
      porciones: map['porciones'],
      porcentajeGanancia: map['porcentajeGanancia']?.toDouble() ?? 0.0,
    );
  }
}

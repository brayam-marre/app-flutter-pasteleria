class Receta {
  int? id;
  String nombre;
  int porciones;

  Receta({
    this.id,
    required this.nombre,
    required this.porciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'porciones': porciones,
    };
  }

  factory Receta.fromMap(Map<String, dynamic> map) {
    return Receta(
      id: map['id'],
      nombre: map['nombre'],
      porciones: map['porciones'],
    );
  }
}

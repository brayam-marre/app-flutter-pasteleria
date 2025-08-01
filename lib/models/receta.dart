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
      id: int.tryParse(map['id'].toString()),
      // Convierte a int aunque venga como String
      nombre: map['nombre'] ?? '',
      porciones: int.tryParse(map['porciones'].toString()) ?? 1,
      porcentajeGanancia: double.tryParse(
          map['porcentajeGanancia'].toString()) ?? 0.0,
      idUsuario: int.tryParse(map['idUsuario'].toString()),
    );
  }
}
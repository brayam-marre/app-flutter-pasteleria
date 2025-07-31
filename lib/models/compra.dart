class Compra {
  int? id;
  String nombre;
  String fecha;
  double total;
  int? idUsuario; // ✅ Agregado

  Compra({
    this.id,
    required this.nombre,
    required this.fecha,
    required this.total,
    this.idUsuario, // ✅ Incluido en el constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'fecha': fecha,
      'total': total,
      'idUsuario': idUsuario, // ✅ Agregado en el mapa
    };
  }

  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'],
      nombre: map['nombre'],
      fecha: map['fecha'],
      total: (map['total'] ?? 0).toDouble(),
      idUsuario: map['idUsuario'], // ✅ Agregado en el fromMap
    );
  }
}

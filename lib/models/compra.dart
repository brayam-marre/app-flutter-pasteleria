class Compra {
  final int? id;
  final String nombre;
  final String fecha;
  final double total;

  Compra({
    this.id,
    required this.nombre,
    required this.fecha,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'fecha': fecha,
      'total': total,
    };
  }

  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'],
      nombre: map['nombre'],
      fecha: map['fecha'],
      total: map['total'],
    );
  }
}

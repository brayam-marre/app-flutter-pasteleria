class Producto {
  int? id;
  String nombre;
  String unidad;
  double cantidad;
  double valor;
  int? idUsuario; // 🔹 Nuevo campo

  Producto({
    this.id,
    required this.nombre,
    required this.unidad,
    required this.cantidad,
    required this.valor,
    this.idUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'unidad': unidad,
      'cantidad': cantidad,
      'valor': valor,
      'idUsuario': idUsuario, // 🔹 Incluido en el mapa
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      unidad: map['unidad'],
      cantidad: (map['cantidad'] ?? 0).toDouble(),
      valor: (map['valor'] ?? 0).toDouble(),
      idUsuario: map['idUsuario'], // 🔹 Lo recuperamos del mapa
    );
  }
}

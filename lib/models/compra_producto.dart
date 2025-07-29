class CompraProducto {
  final int? id;
  final int idCompra;
  final String nombreProducto;
  final String unidad;
  final double peso;
  final double valor;

  CompraProducto({
    this.id,
    required this.idCompra,
    required this.nombreProducto,
    required this.unidad,
    required this.peso,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCompra': idCompra,
      'nombreProducto': nombreProducto,
      'unidad': unidad,
      'peso': peso,
      'valor': valor,
    };
  }

  factory CompraProducto.fromMap(Map<String, dynamic> map) {
    return CompraProducto(
      id: map['id'],
      idCompra: map['idCompra'],
      nombreProducto: map['nombreProducto'],
      unidad: map['unidad'],
      peso: map['peso'],
      valor: map['valor'],
    );
  }

  CompraProducto copyWith({
    int? id,
    int? idCompra,
    String? nombreProducto,
    String? unidad,
    double? peso,
    double? valor,
  }) {
    return CompraProducto(
      id: id ?? this.id,
      idCompra: idCompra ?? this.idCompra,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      unidad: unidad ?? this.unidad,
      peso: peso ?? this.peso,
      valor: valor ?? this.valor,
    );
  }
}

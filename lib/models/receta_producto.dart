class RecetaProducto {
  int? id;
  int idReceta;
  String nombreProducto;
  String unidad;
  double cantidadUsada;
  double costoUnitario;

  RecetaProducto({
    this.id,
    required this.idReceta,
    required this.nombreProducto,
    required this.unidad,
    required this.cantidadUsada,
    required this.costoUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idReceta': idReceta,
      'nombreProducto': nombreProducto,
      'unidad': unidad,
      'cantidadUsada': cantidadUsada,
      'costoUnitario': costoUnitario,
    };
  }

  factory RecetaProducto.fromMap(Map<String, dynamic> map) {
    return RecetaProducto(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      idReceta: int.tryParse(map['idReceta'].toString()) ?? 0,
      nombreProducto: map['nombreProducto']?.toString() ?? '',
      unidad: map['unidad']?.toString() ?? '',
      cantidadUsada: double.tryParse(map['cantidadUsada'].toString()) ?? 0.0,
      costoUnitario: double.tryParse(map['costoUnitario'].toString()) ?? 0.0,
    );
  }

  RecetaProducto copyWith({
    int? id,
    int? idReceta,
    String? nombreProducto,
    String? unidad,
    double? cantidadUsada,
    double? costoUnitario,
  }) {
    return RecetaProducto(
      id: id ?? this.id,
      idReceta: idReceta ?? this.idReceta,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      unidad: unidad ?? this.unidad,
      cantidadUsada: cantidadUsada ?? this.cantidadUsada,
      costoUnitario: costoUnitario ?? this.costoUnitario,
    );
  }
}

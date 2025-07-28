class UnidadMedida {
  String nombre;

  UnidadMedida({required this.nombre});

  factory UnidadMedida.fromJson(Map<String, dynamic> json) {
    return UnidadMedida(nombre: json['nombre']);
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre};
  }
}

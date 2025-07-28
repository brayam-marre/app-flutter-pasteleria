import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unidad_medida.dart';

class UnidadProvider with ChangeNotifier {
  List<UnidadMedida> _unidades = [];

  List<UnidadMedida> get unidades => _unidades;

  UnidadProvider() {
    _cargarUnidades();
  }

  Future<void> _cargarUnidades() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('unidades');
    if (data != null) {
      final decoded = json.decode(data) as List<dynamic>;
      _unidades = decoded
          .map((unidadJson) => UnidadMedida.fromJson(unidadJson))
          .toList();
    } else {
      // Carga inicial por defecto
      _unidades = [
        UnidadMedida(nombre: 'Gramos'),
        UnidadMedida(nombre: 'Mililitros'),
        UnidadMedida(nombre: 'Litros'),
        UnidadMedida(nombre: 'Kilogramos'),
        UnidadMedida(nombre: 'Unidades'),
      ];
      _guardarUnidades();
    }
    notifyListeners();
  }

  Future<void> _guardarUnidades() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_unidades.map((u) => u.toJson()).toList());
    await prefs.setString('unidades', data);
  }

  void agregarUnidad(String nombre) {
    _unidades.add(UnidadMedida(nombre: nombre));
    _guardarUnidades();
    notifyListeners();
  }

  void editarUnidad(int index, String nuevoNombre) {
    _unidades[index].nombre = nuevoNombre;
    _guardarUnidades();
    notifyListeners();
  }

  void eliminarUnidad(int index) {
    _unidades.removeAt(index);
    _guardarUnidades();
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class Consulta {
  final String municipio;
  final String cultivo;
  final String fechaSiembra;
  final DateTime fechaConsulta;

  Consulta({
    required this.municipio,
    required this.cultivo,
    required this.fechaSiembra,
    required this.fechaConsulta,
  });
}

class AppProvider extends ChangeNotifier {
  String? _municipioSeleccionado;
  String? _distritoSeleccionado;
  final List<Consulta> _historial = [];

  String? get municipioSeleccionado => _municipioSeleccionado;
  String? get distritoSeleccionado => _distritoSeleccionado;
  List<Consulta> get historial => List.unmodifiable(_historial);

  void seleccionarMunicipio(String municipio, String distrito) {
    _municipioSeleccionado = municipio;
    _distritoSeleccionado = distrito;
    notifyListeners();
  }

  void agregarConsulta(Consulta consulta) {
    _historial.insert(0, consulta);
    notifyListeners();
  }

  void limpiarSeleccion() {
    _municipioSeleccionado = null;
    _distritoSeleccionado = null;
    notifyListeners();
  }
}

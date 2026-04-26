import 'package:flutter/foundation.dart';
import '../../data/models/cultivo_recomendado.dart';
import '../../data/repositories/recomendacion_repository.dart';

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
  final RecomendacionRepository _repo = RecomendacionRepository();

  String? _municipioSeleccionado;
  String? _distritoSeleccionado;
  List<CultivoRecomendado> _recomendaciones = [];
  ClimaMes? _climaActual;
  bool _cargandoRecomendacion = false;
  final List<Consulta> _historial = [];

  String? get municipioSeleccionado => _municipioSeleccionado;
  String? get distritoSeleccionado => _distritoSeleccionado;
  List<CultivoRecomendado> get recomendaciones =>
      List.unmodifiable(_recomendaciones);
  ClimaMes? get climaActual => _climaActual;
  bool get cargandoRecomendacion => _cargandoRecomendacion;
  List<Consulta> get historial => List.unmodifiable(_historial);

  AppProvider() {
    // Precarga el JSON en segundo plano para que esté listo cuando se necesite
    _repo.cargar();
  }

  void seleccionarMunicipio(String municipio, String distrito) {
    _municipioSeleccionado = municipio;
    _distritoSeleccionado = distrito;
    // Limpia recomendaciones anteriores al cambiar de municipio
    _recomendaciones = [];
    _climaActual = null;
    notifyListeners();
  }

  Future<void> cargarRecomendacion(String municipio, int mes) async {
    _cargandoRecomendacion = true;
    notifyListeners();

    await _repo.cargar(); // no-op si ya está cargado
    _recomendaciones = _repo.getRecomendaciones(municipio, mes);
    _climaActual = _repo.getClima(municipio, mes);

    _cargandoRecomendacion = false;
    notifyListeners();
  }

  void agregarConsulta(Consulta consulta) {
    _historial.insert(0, consulta);
    notifyListeners();
  }

  void limpiarSeleccion() {
    _municipioSeleccionado = null;
    _distritoSeleccionado = null;
    _recomendaciones = [];
    _climaActual = null;
    notifyListeners();
  }
}

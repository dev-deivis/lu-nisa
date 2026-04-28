import 'package:flutter/foundation.dart';
import '../../data/models/cultivo_recomendado.dart';
import '../../data/repositories/recomendacion_repository.dart';
import '../../ml/image_analyzer.dart';

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
  ParcelCondition? _condicionParcela;
  List<CultivoRecomendado> _recomendaciones = [];
  ClimaMes? _climaActual;
  bool _climaCargando = false;
  bool _cargandoRecomendacion = false;
  bool _modoHistorial = false;
  final List<Consulta> _historial = [];

  String? get municipioSeleccionado => _municipioSeleccionado;
  String? get distritoSeleccionado => _distritoSeleccionado;
  ParcelCondition? get condicionParcela => _condicionParcela;
  List<CultivoRecomendado> get recomendaciones =>
      List.unmodifiable(_recomendaciones);
  ClimaMes? get climaActual => _climaActual;
  bool get climaCargando => _climaCargando;
  bool get cargandoRecomendacion => _cargandoRecomendacion;
  bool get modoHistorial => _modoHistorial;
  List<Consulta> get historial => List.unmodifiable(_historial);

  AppProvider() {
    _repo.cargar(); // precarga el JSON en segundo plano
  }

  void seleccionarMunicipio(String municipio, String distrito) {
    _municipioSeleccionado = municipio;
    _distritoSeleccionado = distrito;
    _recomendaciones = [];
    _climaActual = null;
    _climaCargando = true;
    _condicionParcela = null;
    _modoHistorial = false;
    notifyListeners();
    cargarClimaMes(municipio);
  }

  Future<void> verConsultaHistorial(Consulta consulta) async {
    _modoHistorial = true;
    _municipioSeleccionado = consulta.municipio;
    _condicionParcela = null;
    _recomendaciones = [];
    _cargandoRecomendacion = true;
    notifyListeners();

    await _repo.cargar();
    final mes = consulta.fechaConsulta.month;
    _recomendaciones = _repo.getRecomendaciones(consulta.municipio, mes);
    _climaActual = _repo.getClima(consulta.municipio, mes);
    _cargandoRecomendacion = false;
    notifyListeners();
  }

  Future<void> cargarClimaMes(String municipio) async {
    _climaCargando = true;
    notifyListeners();
    await _repo.cargar();
    final mes = DateTime.now().month;
    _climaActual = _repo.getClima(municipio, mes);
    _climaCargando = false;
    notifyListeners();
  }

  void setCondicionParcela(ParcelCondition condicion) {
    _condicionParcela = condicion;
    notifyListeners();
  }

  Future<void> cargarRecomendacion(String municipio, int mes) async {
    _cargandoRecomendacion = true;
    notifyListeners();

    await _repo.cargar(); // no-op si ya cargó

    final condicion = _condicionParcela;
    if (condicion != null) {
      _recomendaciones =
          _repo.getRecomendacionesConFoto(municipio, mes, condicion);
    } else {
      _recomendaciones = _repo.getRecomendaciones(municipio, mes);
    }
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
    _condicionParcela = null;
    _recomendaciones = [];
    _climaActual = null;
    _climaCargando = false;
    _modoHistorial = false;
    notifyListeners();
  }
}

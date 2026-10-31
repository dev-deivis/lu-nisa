import 'package:flutter/foundation.dart';
import '../../data/models/condicion_parcela.dart';
import '../../data/models/cultivo_recomendado.dart';
import '../../data/repositories/recomendacion_repository.dart';
import '../services/backend_service.dart';

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

const _nombresMes = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

class AppProvider extends ChangeNotifier {
  final RecomendacionRepository _repo = RecomendacionRepository();

  String? _municipioSeleccionado;
  String? _distritoSeleccionado;
  CondicionParcela? _condicionParcela;
  Explicacion? _explicacion;
  bool _cargandoExplicacion = false;
  List<CultivoRecomendado> _recomendaciones = [];
  ClimaMes? _climaActual;
  bool _climaCargando = false;
  bool _cargandoRecomendacion = false;
  bool _modoHistorial = false;
  final List<Consulta> _historial = [];

  String? get municipioSeleccionado => _municipioSeleccionado;
  String? get distritoSeleccionado => _distritoSeleccionado;
  CondicionParcela? get condicionParcela => _condicionParcela;
  Explicacion? get explicacion => _explicacion;
  bool get cargandoExplicacion => _cargandoExplicacion;
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
    _explicacion = null;
    _cargandoExplicacion = false;
    _modoHistorial = false;
    notifyListeners();
    cargarClimaMes(municipio);
  }

  Future<void> verConsultaHistorial(Consulta consulta) async {
    _modoHistorial = true;
    _municipioSeleccionado = consulta.municipio;
    _condicionParcela = null;
    _explicacion = null;
    _cargandoExplicacion = false;
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

  /// null = sin foto ni respuesta → ranking base
  void setCondicionParcela(CondicionParcela? condicion) {
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
          _repo.getRecomendacionesConCondicion(municipio, mes, condicion);
    } else {
      _recomendaciones = _repo.getRecomendaciones(municipio, mes);
    }
    _climaActual = _repo.getClima(municipio, mes);

    _cargandoRecomendacion = false;
    notifyListeners();

    // La explicación llega después: no frena la pantalla
    _cargarExplicacion(municipio, mes);
  }

  Future<void> _cargarExplicacion(String municipio, int mes) async {
    _explicacion = null;
    if (_recomendaciones.isEmpty) return;
    final cultivo = _recomendaciones.first;
    final condicion = _condicionParcela;

    _cargandoExplicacion = true;
    notifyListeners();
    final explicacion = await BackendService.explicar(
      municipio: municipio,
      cultivo: cultivo.nombreComun,
      puntaje: cultivo.score,
      mesActual: _nombresMes[mes - 1],
      siembra: _repo.siembra(municipio, mes, cultivo),
      datosRegla: _repo.datosRegla(municipio, mes, cultivo, condicion),
    );
    // Si el usuario cambió de consulta mientras tanto, se descarta
    if (!identical(_recomendaciones.firstOrNull, cultivo)) return;
    _explicacion = explicacion;
    _cargandoExplicacion = false;
    notifyListeners();
  }

  /// Lluvia mensual promedio en los meses de siembra (para la tarjeta de clima)
  double? lluviaEnSiembra(CultivoRecomendado cultivo) {
    final municipio = _municipioSeleccionado;
    if (municipio == null) return null;
    return _repo.lluviaEnSiembra(municipio, cultivo);
  }

  void agregarConsulta(Consulta consulta) {
    _historial.insert(0, consulta);
    notifyListeners();
  }

  void limpiarSeleccion() {
    _municipioSeleccionado = null;
    _distritoSeleccionado = null;
    _condicionParcela = null;
    _explicacion = null;
    _cargandoExplicacion = false;
    _recomendaciones = [];
    _climaActual = null;
    _climaCargando = false;
    _modoHistorial = false;
    notifyListeners();
  }
}

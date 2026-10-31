import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/cultivo_recomendado.dart';
import '../models/condicion_parcela.dart';

const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// Meses (1-12) de un rango como "Octubre-Enero"; maneja el cruce de año.
List<int> mesesDeRango(String rango) {
  final partes = rango
      .toLowerCase()
      .split('-')
      .map((m) => _meses.indexOf(m.trim()) + 1)
      .toList();
  if (partes.isEmpty || partes.any((m) => m == 0)) return [];
  final inicio = partes.first, fin = partes.last;
  final total = (fin - inicio) % 12 + 1;
  return [for (var i = 0; i < total; i++) (inicio - 1 + i) % 12 + 1];
}

class RecomendacionRepository {
  Map<String, dynamic>? _datos;

  Future<void> cargar() async {
    if (_datos != null) return;
    final jsonStr =
        await rootBundle.loadString('assets/data/recomendaciones.json');
    _datos = json.decode(jsonStr) as Map<String, dynamic>;
  }

  // Todos los cultivos del mes sin ordenar ni limitar
  List<CultivoRecomendado> _getTodos(String municipio, int mes) {
    final muni = _datos?[municipio] as Map<String, dynamic>?;
    if (muni == null) return [];
    final porMes =
        muni['recomendaciones_por_mes'] as Map<String, dynamic>?;
    if (porMes == null) return [];
    final lista = porMes['$mes'] as List<dynamic>?;
    if (lista == null) return [];
    return lista
        .map((e) => CultivoRecomendado.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Top 3 sin ajuste de foto
  List<CultivoRecomendado> getRecomendaciones(String municipio, int mes) {
    return (_getTodos(municipio, mes)
          ..sort((a, b) => b.score.compareTo(a.score)))
        .take(3)
        .toList();
  }

  /// Top 3 ajustado según la humedad de la parcela (foto o respuesta del
  /// campesino). Solo hay ajustes relativos entre cultivos: un ajuste igual
  /// para todos no cambia el orden.
  List<CultivoRecomendado> getRecomendacionesConCondicion(
    String municipio,
    int mes,
    CondicionParcela condicion,
  ) {
    final humedad = condicion.humedad;
    final todos = _getTodos(municipio, mes);
    if (todos.isEmpty) return [];

    // Sin dato de humedad ("Poco" o no determinable) → ranking base
    if (humedad == null) {
      return (todos..sort((a, b) => b.score.compareTo(a.score))).take(3).toList();
    }
    final seca = humedad == 'seca';

    final ajustados = todos
        // Filtrado duro: en tierra seca se quitan los cultivos de mucha agua
        .where((c) => !(seca && c.requerimientoAgua == 'alto'))
        .map((c) {
      final score = c.score +
          (seca
              // Poca agua → +15; agua media → -10
              ? switch (c.requerimientoAgua) { 'bajo' => 15, 'medio' => -10, _ => 0 }
              // húmeda / encharcada: mucha agua → +15; poca agua → -5
              : switch (c.requerimientoAgua) { 'alto' => 15, 'bajo' => -5, _ => 0 });

      return CultivoRecomendado(
        cultivo: c.cultivo,
        score: score.clamp(0, 100),
        mesesSiembra: c.mesesSiembra,
        mesesCosecha: c.mesesCosecha,
        notas: c.notas,
        requerimientoAgua: c.requerimientoAgua,
        recomendaciones: c.recomendaciones,
      );
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return ajustados.take(3).toList();
  }

  /// Datos que usó la regla para [cultivo], con su fuente, para POST /explicar.
  /// fuente: 'foto' → "se ve", 'campesino' → "nos dijiste", 'datos' → históricos.
  Map<String, Map<String, Object>> datosRegla(
    String municipio,
    int mes,
    CultivoRecomendado cultivo,
    CondicionParcela? condicion,
  ) {
    Map<String, Object> dato(Object valor, String fuente) =>
        {'valor': valor, 'fuente': fuente};

    final datos = <String, Map<String, Object>>{
      'se_siembra_en_el_municipio': dato(true, 'datos'),
    };

    // Regla base (generar_recomendaciones.py): altitud, temperatura y lluvia del mes
    final altitud = (_datos?[municipio] as Map<String, dynamic>?)?['altitud'];
    if (altitud is num) datos['altitud'] = dato('${altitud.round()} m', 'datos');
    final clima = getClima(municipio, mes);
    if (clima != null) {
      datos['temperatura_promedio_este_mes'] =
          dato('${clima.tempMedia.toStringAsFixed(0)} °C', 'datos');
      datos['lluvia_promedio_este_mes'] =
          dato('${clima.precipitacionMensual.round()} mm', 'datos');
    }

    final humedad = condicion?.humedad;
    if (condicion == null || humedad == null) return datos;

    // Ajuste por humedad
    if (condicion.humedadDeLaFoto) {
      datos['humedad_de_la_tierra'] = dato(switch (humedad) {
        'seca' => 'seca',
        'encharcada' => 'encharcada',
        _ => 'húmeda',
      }, 'foto');
    } else {
      datos['llovio_en_los_ultimos_7_dias'] =
          dato(humedad == 'seca' ? 'no' : 'sí', 'campesino');
    }
    datos['agua_que_necesita_el_cultivo'] = dato(switch (cultivo.requerimientoAgua) {
      'bajo' => 'poca',
      'alto' => 'mucha',
      _ => 'media',
    }, 'datos');
    return datos;
  }

  /// Lluvia mensual promedio (mm) en los meses de siembra del cultivo
  double? lluviaEnSiembra(String municipio, CultivoRecomendado cultivo) {
    final lluvias = [
      for (final m in mesesDeRango(cultivo.mesesSiembra))
        getClima(municipio, m)?.precipitacionMensual,
    ].whereType<double>().toList();
    if (lluvias.isEmpty) return null;
    return lluvias.reduce((a, b) => a + b) / lluvias.length;
  }

  /// Datos de la fecha de siembra para POST /explicar (campo "siembra").
  /// El backend arma con esto la razón; el modelo solo la redacta.
  Map<String, Object> siembra(
    String municipio,
    int mes,
    CultivoRecomendado cultivo,
  ) {
    final lluviaSiembra = lluviaEnSiembra(municipio, cultivo);
    final lluviaActual = getClima(municipio, mes)?.precipitacionMensual;
    return {
      'meses': cultivo.mesesSiembra,
      'se_siembra_este_mes': mesesDeRango(cultivo.mesesSiembra).contains(mes),
      'lluvia_meses_siembra_mm': ?lluviaSiembra,
      'lluvia_mes_actual_mm': ?lluviaActual,
      'agua_cultivo': cultivo.requerimientoAgua,
    };
  }

  ClimaMes? getClima(String municipio, int mes) {
    final muni = _datos?[municipio] as Map<String, dynamic>?;
    if (muni == null) return null;
    final climaMensual = muni['clima_mensual'] as Map<String, dynamic>?;
    if (climaMensual == null) return null;
    final mesData = climaMensual['$mes'] as Map<String, dynamic>?;
    if (mesData == null) return null;
    return ClimaMes.fromJson(mesData);
  }

  bool get estaDisponible => _datos != null;
}

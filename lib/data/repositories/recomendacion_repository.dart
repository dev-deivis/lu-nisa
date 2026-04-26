import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/cultivo_recomendado.dart';
import '../../ml/image_analyzer.dart';

// Keywords en notas que indican alta necesidad hídrica
const _altaAgua = [
  'humedad', 'húmedo', 'lluvia', 'tropical', 'agua', 'riego',
  'precipitación', 'temporal', 'café', 'irrigación',
];

// Keywords en notas que indican baja necesidad hídrica
const _bajaAgua = [
  'seco', 'sequía', 'árido', 'poca agua', 'tolera', 'xerofita',
  'resistente a', 'poca lluvia',
];

bool _prefiereMucha(CultivoRecomendado c) {
  final texto = '${c.notas} ${c.cultivo}'.toLowerCase();
  return _altaAgua.any(texto.contains);
}

bool _prefierePocha(CultivoRecomendado c) {
  final texto = '${c.notas} ${c.cultivo}'.toLowerCase();
  return _bajaAgua.any(texto.contains);
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

  /// Top 3 con scores ajustados según la condición detectada en la foto
  List<CultivoRecomendado> getRecomendacionesConFoto(
    String municipio,
    int mes,
    ParcelCondition condicion,
  ) {
    final todos = _getTodos(municipio, mes);
    if (todos.isEmpty) return [];

    final ajustados = todos.map((c) {
      int score = c.score;

      // Ajuste uniforme de la foto
      score += condicion.scoreAdjustment;

      // Tierra activa (vegetación presente) → +10 a todos
      if (condicion.hasVegetation) score += 10;

      // Diferencial por tipo de suelo vs. necesidad hídrica del cultivo
      if (condicion.soilType == 'humedo') {
        if (_prefiereMucha(c)) score += 8;
        if (_prefierePocha(c)) score -= 5;
      } else if (condicion.soilType == 'seco') {
        if (_prefierePocha(c)) score += 8;
        if (_prefiereMucha(c)) score -= 5;
      }

      return CultivoRecomendado(
        cultivo: c.cultivo,
        score: score.clamp(0, 100),
        mesesSiembra: c.mesesSiembra,
        mesesCosecha: c.mesesCosecha,
        notas: c.notas,
      );
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return ajustados.take(3).toList();
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

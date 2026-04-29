import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/cultivo_recomendado.dart';
import '../../ml/image_analyzer.dart';

// Keywords que indican alta necesidad hídrica
const _altaAgua = [
  'cálido húmedo', 'calido humedo', 'húmedo', 'humedo',
  'lluvia', 'tropical', 'riego', 'precipitación', 'irrigación',
];

// Keywords que indican tolerancia a la sequía
const _toleraSequia = [
  'tolerante a sequía', 'tolerante a sequia',
  'resistente a sequía', 'resistente a sequia',
  'sequía moderada', 'sequia moderada',
];

// Cultivos excluidos para suelo seco (requieren humedad muy alta)
const _excluirEnSeco = [
  'cálido húmedo', 'calido humedo', 'humedad alta',
  'riego constante', 'suelos húmedos', 'suelos humedos',
  'zonas altas húmedas', 'zonas altas humedas', '1845 mm',
];

bool _prefiereMucha(CultivoRecomendado c) {
  final texto = '${c.notas} ${c.cultivo}'.toLowerCase();
  return _altaAgua.any(texto.contains);
}

bool _prefierePocha(CultivoRecomendado c) {
  final texto = '${c.notas} ${c.cultivo}'.toLowerCase();
  return _toleraSequia.any(texto.contains);
}

bool _debeExcluirSeco(CultivoRecomendado c) {
  final texto = '${c.notas} ${c.cultivo}'.toLowerCase();
  return _excluirEnSeco.any(texto.contains);
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

  /// Top 3 con filtrado duro y scores ajustados según la condición del suelo
  List<CultivoRecomendado> getRecomendacionesConFoto(
    String municipio,
    int mes,
    ParcelCondition condicion,
  ) {
    final todos = _getTodos(municipio, mes);
    if (todos.isEmpty) return [];

    // ── Filtrado duro por tipo de suelo ──────────────────────────────────
    final candidatos = todos.where((c) {
      if (condicion.soilType == 'seco') return !_debeExcluirSeco(c);
      // Para húmedo y fértil no excluimos: todos los cultivos de la Sierra
      // Norte pueden crecer en esas condiciones
      return true;
    }).toList();

    // ── Ajuste de score ───────────────────────────────────────────────────
    final ajustados = candidatos.map((c) {
      int score = c.score;

      // Ajuste base de la foto
      score += condicion.scoreAdjustment;

      // Tierra activa (vegetación presente) → +10 a todos
      if (condicion.hasVegetation) score += 10;

      if (condicion.soilType == 'seco') {
        // Cultivos tolerantes a sequía → +15; cultivos que prefieren mucha agua → -30
        if (_prefierePocha(c)) score += 15;
        if (_prefiereMucha(c)) score -= 30;
      } else if (condicion.soilType == 'humedo') {
        // Cultivos que prefieren humedad → +15; tolerantes a sequía → -5 (leve)
        if (_prefiereMucha(c)) score += 15;
        if (_prefierePocha(c)) score -= 5;
      }
      // fértil: sin ajuste adicional, todos compiten con score base

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

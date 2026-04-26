import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/cultivo_recomendado.dart';

class RecomendacionRepository {
  Map<String, dynamic>? _datos;

  Future<void> cargar() async {
    if (_datos != null) return;
    final jsonStr =
        await rootBundle.loadString('assets/data/recomendaciones.json');
    _datos = json.decode(jsonStr) as Map<String, dynamic>;
  }

  /// Retorna hasta 3 cultivos recomendados para el municipio y mes dados,
  /// ordenados por score descendente.
  List<CultivoRecomendado> getRecomendaciones(String municipio, int mes) {
    final muni = _datos?[municipio] as Map<String, dynamic>?;
    if (muni == null) return [];
    final porMes =
        muni['recomendaciones_por_mes'] as Map<String, dynamic>?;
    if (porMes == null) return [];
    final lista = porMes['$mes'] as List<dynamic>?;
    if (lista == null) return [];
    final recomendaciones = lista
        .map((e) => CultivoRecomendado.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return recomendaciones.take(3).toList();
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

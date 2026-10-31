class CultivoRecomendado {
  final String cultivo;
  final int score;
  final String mesesSiembra;
  final String mesesCosecha;
  final String notas;

  /// 'bajo' | 'medio' | 'alto' (columna requerimiento_agua del CSV de cultivos)
  final String requerimientoAgua;

  /// Consejos prácticos reales (columna opcional del CSV). Vacía → no se muestran
  final List<String> recomendaciones;

  const CultivoRecomendado({
    required this.cultivo,
    required this.score,
    required this.mesesSiembra,
    required this.mesesCosecha,
    required this.notas,
    required this.requerimientoAgua,
    this.recomendaciones = const [],
  });

  /// Nombre para mostrar: sin el texto entre paréntesis
  /// ("Calabaza (Cucurbita pepo / C. argyrosperma)" → "Calabaza")
  String get nombreComun =>
      cultivo.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();

  factory CultivoRecomendado.fromJson(Map<String, dynamic> json) {
    return CultivoRecomendado(
      cultivo: json['cultivo'] as String,
      score: (json['score'] as num).toInt(),
      mesesSiembra: json['meses_siembra'] as String,
      mesesCosecha: json['meses_cosecha'] as String,
      notas: json['notas'] as String,
      requerimientoAgua: json['requerimiento_agua'] as String? ?? 'medio',
      recomendaciones:
          (json['recomendaciones'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}

class ClimaMes {
  final double tempMax;
  final double tempMin;
  final double tempMedia;
  /// Promedio DIARIO (mm/día); lo usa el score base del generador
  final double precipitacion;

  /// Lluvia total del mes, promedio 2018-2023 (mm). Es la que se muestra
  final double precipitacionMensual;
  final double humedad;

  const ClimaMes({
    required this.tempMax,
    required this.tempMin,
    required this.tempMedia,
    required this.precipitacion,
    required this.precipitacionMensual,
    required this.humedad,
  });

  factory ClimaMes.fromJson(Map<String, dynamic> json) {
    return ClimaMes(
      tempMax: (json['temp_max'] as num).toDouble(),
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMedia: (json['temp_media'] as num).toDouble(),
      precipitacion: (json['precipitacion'] as num).toDouble(),
      precipitacionMensual:
          (json['precipitacion_mensual'] as num? ?? 0).toDouble(),
      humedad: (json['humedad'] as num).toDouble(),
    );
  }
}

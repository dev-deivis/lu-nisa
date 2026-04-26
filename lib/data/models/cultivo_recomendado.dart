class CultivoRecomendado {
  final String cultivo;
  final int score;
  final String mesesSiembra;
  final String mesesCosecha;
  final String notas;

  const CultivoRecomendado({
    required this.cultivo,
    required this.score,
    required this.mesesSiembra,
    required this.mesesCosecha,
    required this.notas,
  });

  factory CultivoRecomendado.fromJson(Map<String, dynamic> json) {
    return CultivoRecomendado(
      cultivo: json['cultivo'] as String,
      score: (json['score'] as num).toInt(),
      mesesSiembra: json['meses_siembra'] as String,
      mesesCosecha: json['meses_cosecha'] as String,
      notas: json['notas'] as String,
    );
  }
}

class ClimaMes {
  final double tempMax;
  final double tempMin;
  final double tempMedia;
  final double precipitacion;
  final double humedad;

  const ClimaMes({
    required this.tempMax,
    required this.tempMin,
    required this.tempMedia,
    required this.precipitacion,
    required this.humedad,
  });

  factory ClimaMes.fromJson(Map<String, dynamic> json) {
    return ClimaMes(
      tempMax: (json['temp_max'] as num).toDouble(),
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMedia: (json['temp_media'] as num).toDouble(),
      precipitacion: (json['precipitacion'] as num).toDouble(),
      humedad: (json['humedad'] as num).toDouble(),
    );
  }
}

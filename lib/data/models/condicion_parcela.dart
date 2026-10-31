/// Respuesta del campesino a "¿Llovió en tu parcela en los últimos 7 días?"
enum RespuestaLluvia { si, poco, no }

/// Condición observable de la parcela: viene del backend (foto) y/o de la
/// pregunta de lluvia. Nada de fertilidad, nutrientes ni pH.
class CondicionParcela {
  /// 'seca' | 'humeda' | 'encharcada' | null (sin dato → sin ajuste)
  final String? humedad;

  /// 'foto' | 'campesino' (de dónde salió [humedad])
  final String fuenteHumedad;

  /// Solo si la humedad vino de la pregunta
  final RespuestaLluvia? respuestaLluvia;

  // Atributos de la foto; null si no hubo análisis o no se pudo determinar
  final bool esParcela;
  final bool? sueloDesnudo;
  final String? pendiente; // 'plana' | 'moderada' | 'fuerte'
  final String? piedras; // 'pocas' | 'muchas'
  final String? coberturaVegetal; // 'nula' | 'parcial' | 'total'
  final String? observaciones;

  /// Informativo: no se usa en ninguna lógica
  final String? confianza;

  /// Pide al usuario la humedad (el backend usó el modelo local)
  final bool preguntarHumedad;

  /// 'gemini' | 'ollama' | null (sin análisis de foto)
  final String? proveedor;
  final String? modelo;

  const CondicionParcela({
    required this.humedad,
    required this.fuenteHumedad,
    this.respuestaLluvia,
    this.esParcela = true,
    this.sueloDesnudo,
    this.pendiente,
    this.piedras,
    this.coberturaVegetal,
    this.observaciones,
    this.confianza,
    this.preguntarHumedad = false,
    this.proveedor,
    this.modelo,
  });

  static String? _determinado(Object? v) =>
      (v == null || v == 'no_determinable') ? null : v as String;

  /// Construye la condición a partir de la respuesta de POST /analizar-parcela
  factory CondicionParcela.desdeBackend(Map<String, dynamic> json) {
    final a = json['analisis'] as Map<String, dynamic>;
    final desnudo = a['suelo_desnudo'];
    return CondicionParcela(
      humedad: _determinado(a['humedad_aparente']),
      fuenteHumedad: 'foto',
      esParcela: a['es_parcela'] as bool,
      sueloDesnudo: desnudo is bool ? desnudo : null,
      pendiente: _determinado(a['pendiente']),
      piedras: _determinado(a['piedras']),
      coberturaVegetal: a['cobertura_vegetal'] as String?,
      observaciones: a['observaciones'] as String?,
      confianza: a['confianza'] as String?,
      preguntarHumedad: json['humedad_preguntar_usuario'] as bool? ?? false,
      proveedor: json['proveedor'] as String?,
      modelo: json['modelo'] as String?,
    );
  }

  /// Sí → húmeda, No → seca, Poco → sin ajuste
  static String? humedadDeRespuesta(RespuestaLluvia r) => switch (r) {
        RespuestaLluvia.si => 'humeda',
        RespuestaLluvia.no => 'seca',
        RespuestaLluvia.poco => null,
      };

  /// Solo la respuesta del campesino (el backend no respondió)
  factory CondicionParcela.soloRespuesta(RespuestaLluvia r) => CondicionParcela(
        humedad: humedadDeRespuesta(r),
        fuenteHumedad: 'campesino',
        respuestaLluvia: r,
      );

  /// Conserva lo observado en la foto pero toma la humedad del campesino
  CondicionParcela conRespuesta(RespuestaLluvia r) => CondicionParcela(
        humedad: humedadDeRespuesta(r),
        fuenteHumedad: 'campesino',
        respuestaLluvia: r,
        esParcela: esParcela,
        sueloDesnudo: sueloDesnudo,
        pendiente: pendiente,
        piedras: piedras,
        coberturaVegetal: coberturaVegetal,
        observaciones: observaciones,
        confianza: confianza,
        proveedor: proveedor,
        modelo: modelo,
      );

  bool get humedadDeLaFoto => fuenteHumedad == 'foto';

  /// Etiqueta pequeña que se muestra bajo las recomendaciones
  String get etiquetaModelo {
    if (proveedor == 'gemini') return 'Analizado con Gemma 4 26B';
    if (proveedor == 'ollama') return 'Analizado con Gemma 4 local';
    return 'Según lo que nos dijiste';
  }
}

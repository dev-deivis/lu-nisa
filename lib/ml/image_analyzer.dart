import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ParcelCondition {
  final bool hasVegetation;
  final String soilType; // "humedo" | "seco" | "fertil"
  final int scoreAdjustment; // ajuste uniforme para todas las recomendaciones

  const ParcelCondition({
    required this.hasVegetation,
    required this.soilType,
    required this.scoreAdjustment,
  });

  static const sinFoto = ParcelCondition(
    hasVegetation: false,
    soilType: 'fertil',
    scoreAdjustment: 0,
  );
}

class ImageAnalyzer {
  // Umbral bajo para que ML Kit retorne más etiquetas candidatas;
  // los umbrales de clasificación se aplican manualmente abajo.
  static const _umbral = 0.5;

  static Future<ParcelCondition> analyzeParcel(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: _umbral),
    );

    try {
      final labels = await labeler.processImage(inputImage);

      for (final label in labels) {
        debugPrint(
          '[ImageAnalyzer] Etiqueta: ${label.label} - Confidence: ${label.confidence.toStringAsFixed(3)}',
        );
      }

      // Mapa label_en_minúsculas → confidence para consultas O(1)
      final conf = <String, double>{
        for (final l in labels) l.label.toLowerCase(): l.confidence,
      };

      double c(String key) => conf[key] ?? 0.0;

      // ── hasVegetation ──────────────────────────────────────────────────
      // Plant/Forest/Jungle requieren > 0.75; Prairie/Field requieren > 0.70
      final hasVegetation =
          c('plant') > 0.75 ||
          c('forest') > 0.75 ||
          c('jungle') > 0.75 ||
          c('prairie') > 0.70 ||
          c('field') > 0.70;

      // ── soilType ───────────────────────────────────────────────────────
      // Cascada: fértil → seco → húmedo
      // Fértil: bosque/selva claros, o pradera con vegetación activa
      final esFertil =
          c('forest') > 0.75 ||
          c('jungle') > 0.75 ||
          (c('prairie') > 0.75 && hasVegetation);

      // Seco: suelo árido dominante, urban/rock sin bosque, o sin vegetación
      final esSeco =
          c('soil') > 0.75 ||
          !hasVegetation ||
          // Edificios/roca/vía presentes y sin bosque/selva significativo
          ((c('building') > 0.5 || c('rock') > 0.5 || c('road') > 0.5) &&
              c('forest') <= 0.75 &&
              c('jungle') <= 0.75);

      // Húmedo: vegetación presente y suelo no árido dominante
      final esHumedo = hasVegetation && c('soil') < 0.70;

      final String soilType;
      if (esFertil) {
        soilType = 'fertil';
      } else if (esSeco) {
        soilType = 'seco';
      } else if (esHumedo) {
        soilType = 'humedo';
      } else {
        soilType = 'seco';
      }

      // ── scoreAdjustment ────────────────────────────────────────────────
      int adj = switch (soilType) {
        'fertil' => 20,
        'humedo' => 10,
        'seco'   => -15,
        _        => 0,
      };
      if (hasVegetation) adj += 5;

      final condicion = ParcelCondition(
        hasVegetation: hasVegetation,
        soilType: soilType,
        scoreAdjustment: adj.clamp(-20, 20),
      );

      debugPrint(
        '[ImageAnalyzer] Resultado: hasVegetation=${condicion.hasVegetation}, '
        'soilType=${condicion.soilType}, scoreAdjustment=${condicion.scoreAdjustment}',
      );

      return condicion;
    } catch (_) {
      // Si ML Kit falla (modelo no disponible aún), condición neutral
      return ParcelCondition.sinFoto;
    } finally {
      await labeler.close();
    }
  }
}

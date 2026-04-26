import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ParcelCondition {
  final bool hasVegetation;
  final String soilType; // "humedo" | "seco" | "fertil"
  final int scoreAdjustment; // -20..+20, ajuste uniforme para todas las recomendaciones

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
  static const _umbral = 0.55;

  static const _vegetacion = {
    'grass', 'plant', 'tree', 'vegetation', 'leaf', 'nature',
    'crop', 'field', 'agriculture', 'flower', 'shrub', 'herb',
    'jungle', 'forest', 'farmland', 'garden',
  };

  static const _humedo = {
    'water', 'mud', 'swamp', 'rain', 'moist', 'wet', 'puddle',
    'pond', 'stream', 'river', 'lake', 'flood', 'moisture', 'irrigation',
  };

  static const _seco = {
    'desert', 'sand', 'dry', 'rock', 'stone', 'arid', 'dust',
    'drought', 'cracked', 'barren', 'wasteland', 'gravel',
  };

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

      final nombres = labels.map((l) => l.label.toLowerCase()).toSet();

      final hasVegetation = nombres.any(
        (l) => _vegetacion.any((k) => l.contains(k)),
      );
      final isHumedo = nombres.any(
        (l) => _humedo.any((k) => l.contains(k)),
      );
      final isSeco = nombres.any(
        (l) => _seco.any((k) => l.contains(k)),
      );

      final String soilType;
      if (isHumedo && !isSeco) {
        soilType = 'humedo';
      } else if (isSeco && !isHumedo) {
        soilType = 'seco';
      } else {
        soilType = 'fertil';
      }

      // scoreAdjustment refleja la calidad general de la parcela
      int adj = 0;
      if (hasVegetation) adj += 8;
      if (soilType == 'fertil') adj += 5;
      if (soilType == 'humedo') adj += 3;
      if (soilType == 'seco') adj -= 10;

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
      // Si ML Kit falla (modelo no disponible aún), se usa condición neutral
      return ParcelCondition.sinFoto;
    } finally {
      await labeler.close();
    }
  }
}

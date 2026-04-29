import 'dart:io';
import 'dart:ui' as ui;
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

  // Analiza el color promedio de la imagen reducida a 8×8 px para reforzar ML Kit.
  static Future<String?> _colorDominante(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 8,
        targetHeight: 8,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();

      if (byteData == null) return null;

      int rTotal = 0, gTotal = 0, bTotal = 0, count = 0;
      for (int i = 0; i < byteData.lengthInBytes; i += 4) {
        rTotal += byteData.getUint8(i);
        gTotal += byteData.getUint8(i + 1);
        bTotal += byteData.getUint8(i + 2);
        count++;
      }
      if (count == 0) return null;

      final r = rTotal ~/ count;
      final g = gTotal ~/ count;
      final b = bTotal ~/ count;

      debugPrint('[ImageAnalyzer] Color promedio: R=$r G=$g B=$b');

      // Verde intenso → fértil
      if (g > 100 && g > r * 1.2 && g > b * 1.1) return 'fertil';
      // Café/amarillo → seco
      if (r > 150 && g > 100 && b < 80) return 'seco';
      // Gris oscuro/azulado → húmedo
      if (r < 120 && g < 120 && b > 80) return 'humedo';

      return null; // sin señal de color clara
    } catch (e) {
      debugPrint('[ImageAnalyzer] Error en análisis de color: $e');
      return null;
    }
  }

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

      final String mlKitSoilType;
      if (esFertil) {
        mlKitSoilType = 'fertil';
      } else if (esSeco) {
        mlKitSoilType = 'seco';
      } else if (esHumedo) {
        mlKitSoilType = 'humedo';
      } else {
        mlKitSoilType = 'seco'; // fallback sin señal clara
      }

      // ── Análisis de color dominante para reforzar ML Kit ───────────────
      final colorSoilType = await _colorDominante(imagePath);

      // Si ML Kit tuvo señal clara, prevalece. Si fue fallback (sin señal),
      // el color puede corregir la clasificación.
      final mlKitTuvoSenal = esFertil || (esSeco && c('soil') > 0.75) || esHumedo;
      final String soilType;
      if (colorSoilType != null && !mlKitTuvoSenal) {
        soilType = colorSoilType;
      } else {
        soilType = mlKitSoilType;
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

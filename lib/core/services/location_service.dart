import 'package:geolocator/geolocator.dart';
import '../data/municipios_data.dart';

class LocationService {
  /// Solicita permiso de ubicación. Devuelve el estado del permiso.
  static Future<LocationPermission> solicitarPermiso() async {
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    return permiso;
  }

  /// Obtiene la posición GPS actual con timeout de 10 segundos.
  /// Devuelve null si falla o hay timeout.
  static Future<Position?> obtenerPosicion() async {
    try {
      return await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      return null;
    }
  }

  /// Verifica si las coordenadas están dentro de la Sierra Norte de Oaxaca
  /// usando cajas delimitadoras aproximadas por distrito (sin internet).
  static bool estaDentroSierraNorte(double lat, double lng) {
    // Distrito Ixtlán de Juárez
    if (lat >= 17.15 && lat <= 17.60 && lng >= -96.68 && lng <= -96.25) {
      return true;
    }
    // Distrito Villa Alta
    if (lat >= 17.10 && lat <= 17.45 && lng >= -96.35 && lng <= -95.85) {
      return true;
    }
    // Distrito Mixe (incluye San Juan Guichicovi al extremo este)
    if (lat >= 16.60 && lat <= 17.35 && lng >= -96.25 && lng <= -94.90) {
      return true;
    }
    return false;
  }

  /// Detecta el municipio más cercano usando el centroide más próximo.
  /// Devuelve null si el punto está fuera de la Sierra Norte.
  static ({String municipio, String distrito})? detectarMunicipio(
    double lat,
    double lng,
  ) {
    if (!estaDentroSierraNorte(lat, lng)) return null;

    String? nearestMunicipio;
    String? nearestDistrito;
    double minDistSq = double.infinity;

    for (final distEntry in municipioCentroides.entries) {
      final distrito = distEntry.key;
      for (final munEntry in distEntry.value.entries) {
        final c = munEntry.value;
        final dLat = lat - c[0];
        final dLng = lng - c[1];
        final distSq = dLat * dLat + dLng * dLng;
        if (distSq < minDistSq) {
          minDistSq = distSq;
          nearestMunicipio = munEntry.key;
          nearestDistrito = distrito;
        }
      }
    }

    if (nearestMunicipio == null) return null;
    return (municipio: nearestMunicipio, distrito: nearestDistrito!);
  }
}

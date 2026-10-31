import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/condicion_parcela.dart';

/// Explicación generada por POST /explicar
class Explicacion {
  final String texto;
  final String proveedor;
  final String modelo;

  const Explicacion({
    required this.texto,
    required this.proveedor,
    required this.modelo,
  });
}

/// Cliente del backend FastAPI (lunisa/backend).
class BackendService {
  static const _claveUrl = 'backend_url';

  /// Se puede fijar al compilar: flutter run --dart-define=BACKEND_URL=http://192.168.1.50:8000
  static const urlPorDefecto = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://192.168.1.100:8000',
  );

  static const _timeoutAnalisis = Duration(seconds: 90);
  static const _timeoutExplicar = Duration(seconds: 60);

  static Future<String> obtenerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_claveUrl) ?? urlPorDefecto;
    } catch (_) {
      return urlPorDefecto;
    }
  }

  static Future<void> guardarUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveUrl, url.trim().replaceAll(RegExp(r'/+$'), ''));
  }

  /// Envía la foto (ya reducida a 1024 px por image_picker).
  /// Lanza excepción si el backend no responde o responde con error.
  static Future<CondicionParcela> analizarParcela(File foto) async {
    final url = await obtenerUrl();
    final peticion = http.MultipartRequest('POST', Uri.parse('$url/analizar-parcela'))
      ..files.add(await http.MultipartFile.fromPath('imagen', foto.path));

    final respuesta = await http.Response.fromStream(
      await peticion.send().timeout(_timeoutAnalisis),
    );
    if (respuesta.statusCode != 200) {
      throw HttpException('analizar-parcela ${respuesta.statusCode}: ${respuesta.body}');
    }
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
    debugPrint('[Backend] ${json['proveedor']} ${json['latencia_ms']} ms → ${json['analisis']}');
    return CondicionParcela.desdeBackend(json);
  }

  /// [datosRegla]: clave → {'valor': ..., 'fuente': 'foto'|'campesino'|'datos'}.
  /// Devuelve null si falla: la explicación es opcional.
  static Future<Explicacion?> explicar({
    required String municipio,
    required String cultivo,
    required int puntaje,
    required String mesActual,
    required Map<String, Object> siembra,
    required Map<String, Map<String, Object>> datosRegla,
  }) async {
    try {
      final url = await obtenerUrl();
      final respuesta = await http
          .post(
            Uri.parse('$url/explicar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'municipio': municipio,
              'cultivo': cultivo,
              'puntaje': puntaje,
              'mes_actual': mesActual,
              'siembra': siembra,
              'datos_regla': datosRegla,
            }),
          )
          .timeout(_timeoutExplicar);
      if (respuesta.statusCode != 200) {
        debugPrint('[Backend] explicar ${respuesta.statusCode}: ${respuesta.body}');
        return null;
      }
      final json = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
      return Explicacion(
        texto: json['explicacion'] as String,
        proveedor: json['proveedor'] as String,
        modelo: json['modelo'] as String,
      );
    } catch (e) {
      debugPrint('[Backend] explicar falló: $e');
      return null;
    }
  }

  /// GET /salud con la URL dada; true si responde 200
  static Future<bool> probarConexion(String url) async {
    try {
      final r = await http
          .get(Uri.parse('${url.trim().replaceAll(RegExp(r'/+$'), '')}/salud'))
          .timeout(const Duration(seconds: 5));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

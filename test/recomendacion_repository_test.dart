import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunisa/data/models/condicion_parcela.dart';
import 'package:lunisa/data/repositories/recomendacion_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const seca = CondicionParcela(humedad: 'seca', fuenteHumedad: 'foto');
  const humeda = CondicionParcela(humedad: 'humeda', fuenteHumedad: 'foto');

  late RecomendacionRepository repo;
  late List<String> municipios;

  setUpAll(() async {
    repo = RecomendacionRepository();
    await repo.cargar();
    final json = jsonDecode(
        await rootBundle.loadString('assets/data/recomendaciones.json')) as Map;
    municipios = json.keys.cast<String>().toList();
  });

  test('mesesDeRango maneja rangos normales y cruce de año', () {
    expect(mesesDeRango('Mayo-Junio'), [5, 6]);
    expect(mesesDeRango('Octubre-Enero'), [10, 11, 12, 1]);
    expect(mesesDeRango('Mayo-Septiembre'), [5, 6, 7, 8, 9]);
    expect(mesesDeRango('Diciembre-Enero'), [12, 1]);
    expect(mesesDeRango('texto raro'), isEmpty);
  });

  test('tierra seca nunca recomienda cultivos de mucha agua', () {
    for (final m in municipios) {
      for (var mes = 1; mes <= 12; mes++) {
        final top = repo.getRecomendacionesConCondicion(m, mes, seca);
        expect(
          top.where((c) => c.requerimientoAgua == 'alto'),
          isEmpty,
          reason: '$m mes $mes: ${top.map((c) => c.cultivo)}',
        );
      }
    }
  });

  test('tierra húmeda no quita cultivos (solo reordena)', () {
    for (final m in municipios) {
      for (var mes = 1; mes <= 12; mes++) {
        final base = repo.getRecomendaciones(m, mes);
        final top = repo.getRecomendacionesConCondicion(m, mes, humeda);
        expect(top.length, base.length, reason: '$m mes $mes');
      }
    }
  });

  test('datosRegla usa lluvia mensual y siembra trae la fecha', () {
    const m = 'Guelatao de Juárez';
    final cultivo = repo.getRecomendaciones(m, 10).first;
    final datos = repo.datosRegla(m, 10, cultivo, seca);
    final siembra = repo.siembra(m, 10, cultivo);

    // Lluvia total del mes (141 mm), no el promedio diario (4.5 mm)
    expect(datos['lluvia_promedio_este_mes'], {'valor': '141 mm', 'fuente': 'datos'});
    expect(datos['humedad_de_la_tierra'], {'valor': 'seca', 'fuente': 'foto'});
    expect(siembra['meses'], cultivo.mesesSiembra);
    expect(siembra['se_siembra_este_mes'],
        mesesDeRango(cultivo.mesesSiembra).contains(10));
    expect(siembra['lluvia_mes_actual_mm'], 141);
  });

  test('nombreComun quita el texto entre paréntesis', () {
    final todos = [
      for (final m in municipios)
        for (var mes = 1; mes <= 12; mes++) ...repo.getRecomendaciones(m, mes),
    ];
    final calabaza = todos.firstWhere((c) => c.cultivo.startsWith('Calabaza'));
    expect(calabaza.nombreComun, 'Calabaza');
    expect(todos.every((c) => !c.nombreComun.contains('(')), isTrue);
  });
}

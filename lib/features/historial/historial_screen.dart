import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historial = context.watch<AppProvider>().historial;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/recomendacion'),
        ),
      ),
      body: historial.isEmpty
          ? _HistorialVacio()
          : _ListaConsultas(consultas: historial),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/municipio'),
        backgroundColor: AppTheme.verde,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva consulta',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _HistorialVacio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            const Text(
              'Sin consultas aún',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textoPrincipal),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tus recomendaciones de cultivo aparecerán aquí cuando hagas una consulta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textoSecundario,
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/municipio'),
                icon: const Icon(Icons.eco_rounded),
                label: const Text('Hacer consulta'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaConsultas extends StatelessWidget {
  final List<Consulta> consultas;
  const _ListaConsultas({required this.consultas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EncabezadoContador(total: consultas.length),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: consultas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _TarjetaConsulta(consulta: consultas[i]),
          ),
        ),
      ],
    );
  }
}

class _EncabezadoContador extends StatelessWidget {
  final int total;
  const _EncabezadoContador({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.fondoCalido,
      child: Text(
        '$total ${total == 1 ? 'consulta realizada' : 'consultas realizadas'}',
        style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textoSecundario,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TarjetaConsulta extends StatelessWidget {
  final Consulta consulta;
  const _TarjetaConsulta({required this.consulta});

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.verdeMuy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🌽', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consulta.cultivo,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textoPrincipal),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 14, color: AppTheme.tierra),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          consulta.municipio,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textoSecundario),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppTheme.maizOscuro),
                      const SizedBox(width: 4),
                      Text(
                        'Siembra: ${consulta.fechaSiembra}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textoSecundario),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatearFecha(consulta.fechaConsulta),
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textoSecundario),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

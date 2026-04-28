import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../data/models/cultivo_recomendado.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF012D1D)),
          onPressed: () {},
        ),
        title: const Text(
          'Lu nisa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF012D1D),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC1ECD4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC1C8C2)),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF274E3D),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(height: 1.5, color: const Color(0xFFE5E2DD)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _WeatherWidget(),
            const SizedBox(height: 24),
            _AnalizarButton(onTap: () => context.go('/camara')),
            const SizedBox(height: 24),
            _HistorialSection(onVerTodo: () => context.go('/historial')),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const LunisaBottomNav(),
    );
  }
}

class _WeatherWidget extends StatelessWidget {
  const _WeatherWidget();

  static _ClimaInfo _infoFromClima(ClimaMes clima) {
    final p = clima.precipitacion;
    if (p > 100) {
      return _ClimaInfo('Muy lluvioso', Icons.thunderstorm,
          const Color(0xFFD0E8FF), const Color(0xFF1A4D7A));
    } else if (p > 50) {
      return _ClimaInfo('Lluvioso', Icons.water_drop,
          const Color(0xFFD0E8FF), const Color(0xFF1A4D7A));
    } else if (p > 20) {
      return _ClimaInfo('Nublado', Icons.cloud,
          const Color(0xFFE8E8E8), const Color(0xFF444444));
    } else if (clima.tempMedia >= 22) {
      return _ClimaInfo('Soleado', Icons.light_mode,
          const Color(0xFFFFDCC1), const Color(0xFF58330C));
    } else {
      return _ClimaInfo('Fresco', Icons.wb_sunny_outlined,
          const Color(0xFFD4EFD4), const Color(0xFF1A4D2A));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final municipio = provider.municipioSeleccionado;
        final clima = provider.climaActual;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E2DD), width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: municipio == null
              ? _SinMunicipio(onTap: () => context.go('/municipio?from=inicio'))
              : provider.climaCargando
                  ? const _CargandoClima()
                  : clima != null
                      ? _ClimaDetalle(
                          municipio: municipio,
                          clima: clima,
                          info: _infoFromClima(clima),
                          onCambiar: () => context.go('/municipio?from=inicio'),
                        )
                      : _SinDatos(
                          municipio: municipio,
                          onCambiar: () => context.go('/municipio?from=inicio'),
                        ),
        );
      },
    );
  }
}

class _ClimaInfo {
  final String condicion;
  final IconData icono;
  final Color iconBg;
  final Color iconColor;
  const _ClimaInfo(this.condicion, this.icono, this.iconBg, this.iconColor);
}

class _SinMunicipio extends StatelessWidget {
  final VoidCallback onTap;
  const _SinMunicipio({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFECF5F0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.place_outlined,
              size: 32, color: Color(0xFF012D1D)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu ubicación',
                style: TextStyle(fontSize: 13, color: Color(0xFF737977)),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF012D1D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Selecciona tu municipio',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CargandoClima extends StatelessWidget {
  const _CargandoClima();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 64,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF012D1D),
          ),
        ),
      ),
    );
  }
}

class _ClimaDetalle extends StatelessWidget {
  final String municipio;
  final ClimaMes clima;
  final _ClimaInfo info;
  final VoidCallback onCambiar;

  const _ClimaDetalle({
    required this.municipio,
    required this.clima,
    required this.info,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: info.iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(info.icono, size: 36, color: info.iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      municipio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF414844),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCambiar,
                    child: const Text(
                      'Cambiar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF012D1D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${clima.tempMedia.round()}°C',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C19),
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    info.condicion,
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF414844)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalizarButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AnalizarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_a_photo, size: 22),
        label: const Text(
          'Analizar mi parcela',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF012D1D),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _HistorialSection extends StatelessWidget {
  final VoidCallback onVerTodo;
  const _HistorialSection({required this.onVerTodo});

  static String _emoji(String cultivo) {
    final c = cultivo.toLowerCase();
    if (c.contains('maíz') || c.contains('maiz')) return '🌽';
    if (c.contains('frijol')) return '🫘';
    if (c.contains('chile')) return '🌶️';
    if (c.contains('tomate')) return '🍅';
    if (c.contains('café') || c.contains('cafe')) return '☕';
    if (c.contains('durazno')) return '🍑';
    if (c.contains('manzana')) return '🍎';
    if (c.contains('trigo')) return '🌾';
    if (c.contains('aguacate')) return '🥑';
    return '🌱';
  }

  static String _fecha(DateTime d) {
    final ahora = DateTime.now();
    final diff = ahora.difference(d);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final historial = provider.historial;
        final recientes = historial.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de análisis',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C19),
              ),
            ),
            const SizedBox(height: 12),
            if (recientes.isEmpty)
              _SinHistorial(onAnalizar: () => context.go('/camara'))
            else
              ...recientes.map((consulta) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HistorialCard(
                      emoji: _emoji(consulta.cultivo),
                      titulo: consulta.cultivo,
                      subtitulo: '${consulta.municipio} · ${_fecha(consulta.fechaConsulta)}',
                    ),
                  )),
            const SizedBox(height: 4),
            if (historial.isNotEmpty)
              Center(
                child: TextButton.icon(
                  onPressed: onVerTodo,
                  icon: const Text(
                    'Ver todo el historial',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF012D1D),
                    ),
                  ),
                  label: const Icon(Icons.arrow_forward,
                      size: 16, color: Color(0xFF012D1D)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SinHistorial extends StatelessWidget {
  final VoidCallback onAnalizar;
  const _SinHistorial({required this.onAnalizar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2DD), width: 1.5),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          const Text(
            'Sin análisis aún',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C19)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Analiza tu parcela para ver el historial aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF737977)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onAnalizar,
            child: const Text(
              'Analizar ahora',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF012D1D)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorialCard extends StatelessWidget {
  final String emoji;
  final String titulo;
  final String subtitulo;

  const _HistorialCard({
    required this.emoji,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2DD), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('/historial'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA4F792),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C19),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF414844),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF737977)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SinDatos extends StatelessWidget {
  final String municipio;
  final VoidCallback onCambiar;
  const _SinDatos({required this.municipio, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: Icon(Icons.cloud_off_outlined,
                size: 32, color: Color(0xFF737977)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      municipio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF414844)),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCambiar,
                    child: const Text('Cambiar',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF012D1D),
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Datos climáticos no disponibles',
                style: TextStyle(fontSize: 13, color: Color(0xFF737977)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


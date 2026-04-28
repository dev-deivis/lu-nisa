import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/cultivo_recomendado.dart';
import '../../ml/image_analyzer.dart';

// Paleta del diseño HTML
const _kPrimary = Color(0xFF012d1d);
const _kSecondary = Color(0xFF1f6d1a);
const _kSecondaryContainer = Color(0xFFa4f792);
const _kBackground = Color(0xFFfcf9f4);
const _kSurface = Color(0xFFffffff);
const _kOnSurface = Color(0xFF1c1c19);
const _kOnSurfaceVariant = Color(0xFF414844);
const _kOutlineVariant = Color(0xFFc1c8c2);
const _kOutline = Color(0xFF717973);
const _kPrimaryFixed = Color(0xFFc1ecd4);
const _kPrimaryContainer = Color(0xFF1b4332);
const _kSecondaryFixed = Color(0xFFa4f792);
const _kSecondaryFixedDim = Color(0xFF89da79);
const _kOnSecondaryContainer = Color(0xFF267320);
const _kTertiaryFixed = Color(0xFFffdcc1);
const _kOnTertiaryFixedVariant = Color(0xFF653e17);
const _kSurfaceContainer = Color(0xFFf0ede8);
const _kSurfaceContainerLow = Color(0xFFf6f3ee);

String _emojiCultivo(String cultivo) {
  final c = cultivo.toLowerCase();
  if (c.contains('maíz') || c.contains('maiz')) return '🌽';
  if (c.contains('frijol')) return '🫘';
  if (c.contains('chile')) return '🌶️';
  if (c.contains('tomate')) return '🍅';
  if (c.contains('quelite')) return '🥬';
  if (c.contains('durazno')) return '🍑';
  if (c.contains('manzana')) return '🍎';
  if (c.contains('trigo')) return '🌾';
  if (c.contains('café') || c.contains('cafe')) return '☕';
  if (c.contains('aguacate')) return '🥑';
  if (c.contains('calabaza')) return '🎃';
  if (c.contains('papa')) return '🥔';
  if (c.contains('zanahoria')) return '🥕';
  if (c.contains('epazote')) return '🌿';
  return '🌱';
}

String _descripcionClima(double precipitacion) {
  if (precipitacion < 20) return 'Tiempo Seco';
  if (precipitacion < 50) return 'Lluvia Ligera';
  if (precipitacion < 100) return 'Lluvia Moderada';
  return 'Lluvia Intensa';
}

IconData _iconaClima(double precipitacion) {
  if (precipitacion < 20) return Icons.wb_sunny_rounded;
  if (precipitacion < 50) return Icons.water_drop_outlined;
  return Icons.water_rounded;
}

List<String> _parsearNotas(String notas) {
  if (notas.isEmpty) return [];
  final partes = notas
      .split(RegExp(r'[.;]+\s*'))
      .where((s) => s.trim().length > 5)
      .toList();
  return partes.take(3).toList();
}

class RecomendacionScreen extends StatefulWidget {
  const RecomendacionScreen({super.key});

  @override
  State<RecomendacionScreen> createState() => _RecomendacionScreenState();
}

class _RecomendacionScreenState extends State<RecomendacionScreen> {
  bool _consultaGuardada = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // En modo historial los datos ya se están cargando desde el provider
      if (!context.read<AppProvider>().modoHistorial) {
        _cargarDatos();
      }
    });
  }

  Future<void> _cargarDatos() async {
    final provider = context.read<AppProvider>();
    final municipio = provider.municipioSeleccionado ?? '';
    final mes = DateTime.now().month;
    await provider.cargarRecomendacion(municipio, mes);
    _guardarEnHistorial();
  }

  void _guardarEnHistorial() {
    if (_consultaGuardada) return;
    final provider = context.read<AppProvider>();
    if (provider.recomendaciones.isEmpty) return;
    _consultaGuardada = true;
    provider.agregarConsulta(Consulta(
      municipio: provider.municipioSeleccionado ?? '',
      cultivo: provider.recomendaciones.first.cultivo,
      fechaSiembra: provider.recomendaciones.first.mesesSiembra,
      fechaConsulta: DateTime.now(),
    ));
  }

  void _onGuardar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Consulta guardada en historial'),
        backgroundColor: _kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Ver',
          textColor: _kSecondaryContainer,
          onPressed: () => context.go('/historial'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final municipio = provider.municipioSeleccionado ?? 'tu municipio';

    final modoHistorial = provider.modoHistorial;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(modoHistorial ? '/historial' : '/camara');
        }
      },
      child: Scaffold(
        backgroundColor: _kBackground,
        appBar: _LunisaAppBar(
          modoHistorial: modoHistorial,
          onBack: () => context.go(modoHistorial ? '/historial' : '/camara'),
        ),
        body: provider.cargandoRecomendacion
            ? const _EstadoCargando()
            : provider.recomendaciones.isEmpty
                ? _SinDatos(municipio: municipio)
                : _Contenido(
                    provider: provider,
                    onGuardar: modoHistorial ? null : _onGuardar,
                  ),
      ),
    );
  }
}

class _LunisaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool modoHistorial;
  final VoidCallback onBack;

  const _LunisaAppBar({
    required this.modoHistorial,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(57);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _kSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
      leading: IconButton(
        icon: Icon(
          modoHistorial ? Icons.arrow_back_rounded : Icons.menu_rounded,
          color: _kOnSurfaceVariant,
        ),
        onPressed: modoHistorial ? onBack : () {},
      ),
      title: Text(
        modoHistorial ? 'Análisis guardado' : 'Lu nisa',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: _kPrimary,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: _kOutlineVariant,
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}

class _EstadoCargando extends StatelessWidget {
  const _EstadoCargando();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _kSecondary),
          SizedBox(height: 20),
          Text(
            'Consultando datos del cultivo...',
            style: TextStyle(fontSize: 16, color: _kOnSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SinDatos extends StatelessWidget {
  final String municipio;
  const _SinDatos({required this.municipio});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌾', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Sin datos para $municipio',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _kOnSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No se encontraron recomendaciones para este mes.',
              style: TextStyle(fontSize: 14, color: _kOnSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => context.go('/municipio'),
              style: FilledButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Cambiar municipio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  final AppProvider provider;
  final VoidCallback? onGuardar;

  const _Contenido({required this.provider, required this.onGuardar});

  @override
  Widget build(BuildContext context) {
    final cultivo = provider.recomendaciones.first;
    final clima = provider.climaActual;
    final condicion = provider.condicionParcela;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Análisis Completado',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _kOnSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Basado en las condiciones de tu parcela en ${provider.municipioSeleccionado ?? ''}.',
            style: const TextStyle(fontSize: 14, color: _kOnSurfaceVariant),
          ),
          const SizedBox(height: 20),

          _TarjetaPrincipal(cultivo: cultivo, condicion: condicion),
          const SizedBox(height: 16),

          _BotonesAccion(onGuardar: onGuardar),
          const SizedBox(height: 20),

          _BentoGrid(clima: clima, condicion: condicion),
          const SizedBox(height: 20),

          _RecomendacionesPracticas(notas: cultivo.notas),
        ],
      ),
    );
  }
}

class _TarjetaPrincipal extends StatelessWidget {
  final CultivoRecomendado cultivo;
  final ParcelCondition? condicion;

  const _TarjetaPrincipal({required this.cultivo, required this.condicion});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Hero área con gradiente + emoji
          Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1b4332), Color(0xFF2D6A4F), Color(0xFF52B788)],
              ),
            ),
            child: Center(
              child: Text(
                _emojiCultivo(cultivo.cultivo),
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Card cultivo recomendado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🌱 CULTIVO RECOMENDADO',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: _kPrimaryFixed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.eco_rounded,
                              color: _kSecondaryFixed, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cultivo.cultivo,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Badge fecha de siembra
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _kSecondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kSecondaryFixedDim, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month_rounded,
                            color: _kSecondary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📅 Mejor fecha de siembra',
                              style: TextStyle(
                                fontSize: 12,
                                color: _kOnSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cultivo.mesesSiembra,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _kPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (condicion != null) ...[
                  const SizedBox(height: 12),
                  _BadgeParcela(condicion: condicion!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeParcela extends StatelessWidget {
  final ParcelCondition condicion;
  const _BadgeParcela({required this.condicion});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg, icon) = switch (condicion.soilType) {
      'humedo' => (
          'Suelo húmedo 🌧️',
          const Color(0xFF1565C0),
          const Color(0xFFE3F2FD),
          Icons.water_drop_rounded,
        ),
      'seco' => (
          'Suelo seco ☀️',
          const Color(0xFFE65100),
          const Color(0xFFFFF3E0),
          Icons.wb_sunny_rounded,
        ),
      _ => (
          'Tierra fértil 🌱',
          _kSecondary,
          const Color(0xFFE8F5E9),
          Icons.eco_rounded,
        ),
    };

    return Wrap(
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: color.withAlpha(77)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        if (condicion.hasVegetation)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _kSecondary.withAlpha(77)),
            ),
            child: const Text(
              '🌿 Tierra activa',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _BotonesAccion extends StatelessWidget {
  final VoidCallback? onGuardar;
  const _BotonesAccion({required this.onGuardar});

  @override
  Widget build(BuildContext context) {
    // Modo historial: solo botón "Volver al historial"
    if (onGuardar == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => context.go('/historial'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _kPrimary,
            side: const BorderSide(color: _kPrimary, width: 2),
            minimumSize: const Size(0, 56),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)),
          ),
          icon: const Icon(Icons.history_rounded),
          label: const Text('Volver al historial',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      );
    }

    // Modo análisis normal: Guardar + Nueva consulta
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onGuardar,
            style: FilledButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            icon: const Icon(Icons.save_rounded),
            label: const Text('Guardar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/municipio'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kOnSurface,
              side: const BorderSide(color: _kOutline, width: 2),
              minimumSize: const Size(0, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Nueva consulta',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final ClimaMes? clima;
  final ParcelCondition? condicion;

  const _BentoGrid({required this.clima, required this.condicion});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TarjetaCondicionSuelo(clima: clima, condicion: condicion)),
        const SizedBox(width: 12),
        Expanded(child: _TarjetaClima(clima: clima)),
      ],
    );
  }
}

class _TarjetaCondicionSuelo extends StatelessWidget {
  final ClimaMes? clima;
  final ParcelCondition? condicion;

  const _TarjetaCondicionSuelo(
      {required this.clima, required this.condicion});

  String _phEstimado(String? soilType) => switch (soilType) {
        'humedo' => '5.5 - 6.5',
        'seco' => '7.0 - 8.0',
        _ => '6.5 - 7.0',
      };

  String _humedadEtiqueta(double h) {
    if (h > 70) return 'Alta';
    if (h > 40) return 'Óptima';
    return 'Baja';
  }

  String _nitrogenoEtiqueta(String? soilType) => switch (soilType) {
        'fertil' => 'Alto',
        'humedo' => 'Medio',
        _ => 'Bajo',
      };

  @override
  Widget build(BuildContext context) {
    final soilType = condicion?.soilType;
    final humedad = clima?.humedad ?? 60;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terrain_rounded,
                  color: _kOnTertiaryFixedVariant, size: 18),
              const SizedBox(width: 6),
              const Flexible(
                child: Text(
                  'Condiciones del Suelo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kOnSurface,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 16, color: Colors.grey.shade200),
          _FilaInfo(
            icon: Icons.science_rounded,
            label: 'pH Est.',
            valor: _phEstimado(soilType),
            colorValor: _kOnSurface,
            bgValor: _kSurfaceContainer,
          ),
          const SizedBox(height: 8),
          _FilaInfo(
            icon: Icons.water_drop_rounded,
            label: 'Humedad',
            valor: _humedadEtiqueta(humedad),
            colorValor: _kOnSecondaryContainer,
            bgValor: _kSecondaryFixed,
          ),
          const SizedBox(height: 8),
          _FilaInfo(
            icon: Icons.grass_rounded,
            label: 'Nitrógeno',
            valor: _nitrogenoEtiqueta(soilType),
            colorValor: _kOnTertiaryFixedVariant,
            bgValor: const Color(0xFFf5bb89),
          ),
        ],
      ),
    );
  }
}

class _FilaInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color colorValor;
  final Color bgValor;

  const _FilaInfo({
    required this.icon,
    required this.label,
    required this.valor,
    required this.colorValor,
    required this.bgValor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _kOnSurfaceVariant),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: _kOnSurfaceVariant),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bgValor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            valor,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorValor,
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaClima extends StatelessWidget {
  final ClimaMes? clima;
  const _TarjetaClima({required this.clima});

  @override
  Widget build(BuildContext context) {
    final precipitacion = clima?.precipitacion ?? 0;
    final tempMedia = clima?.tempMedia ?? 0;
    final humedad = clima?.humedad ?? 0;
    final descripcion = _descripcionClima(precipitacion);
    final iconaLluvia = _iconaClima(precipitacion);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_rounded, color: _kSecondary, size: 18),
              SizedBox(width: 6),
              Text(
                'Clima Esperado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kOnSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${tempMedia.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: _kOnSurface,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      descripcion,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kPrimary,
                      ),
                    ),
                    Text(
                      '${precipitacion.toStringAsFixed(0)} mm · ${humedad.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 11, color: _kOnSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: _kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DiaClima(dia: 'Lun', icon: iconaLluvia, color: _kSecondary),
                _DiaClima(
                    dia: 'Mar',
                    icon: Icons.cloud_rounded,
                    color: _kOnSurfaceVariant),
                _DiaClima(dia: 'Mié', icon: iconaLluvia, color: _kSecondary),
                _DiaClima(
                    dia: 'Jue',
                    icon: Icons.wb_sunny_rounded,
                    color: const Color(0xFFE65100)),
                _DiaClima(
                    dia: 'Vie',
                    icon: Icons.wb_sunny_rounded,
                    color: const Color(0xFFE65100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaClima extends StatelessWidget {
  final String dia;
  final IconData icon;
  final Color color;

  const _DiaClima(
      {required this.dia, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(dia,
            style: const TextStyle(fontSize: 10, color: _kOnSurfaceVariant)),
        const SizedBox(height: 3),
        Icon(icon, size: 16, color: color),
      ],
    );
  }
}

class _RecomendacionesPracticas extends StatelessWidget {
  final String notas;
  const _RecomendacionesPracticas({required this.notas});

  static const _iconsCfg = [
    (
      icon: Icons.agriculture_rounded,
      bg: _kTertiaryFixed,
      color: _kOnTertiaryFixedVariant,
      titulo: 'Preparación de Tierra',
    ),
    (
      icon: Icons.water_drop_rounded,
      bg: _kPrimaryFixed,
      color: Color(0xFF274e3d),
      titulo: 'Riego y Humedad',
    ),
    (
      icon: Icons.pest_control_rounded,
      bg: Color(0xFFe5e2dd),
      color: _kOnSurfaceVariant,
      titulo: 'Control de Plagas',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _parsearNotas(notas);
    if (items.isEmpty && notas.isEmpty) return const SizedBox.shrink();

    final displayItems = items.isNotEmpty ? items : [notas];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recomendaciones Prácticas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _kOnSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...displayItems.asMap().entries.map((entry) {
          final i = entry.key % _iconsCfg.length;
          final cfg = _iconsCfg[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kOutlineVariant, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 1)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cfg.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cfg.icon, color: cfg.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cfg.titulo,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _kOnSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value.trim(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: _kOnSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

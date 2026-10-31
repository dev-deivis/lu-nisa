import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/cultivo_recomendado.dart';
import '../../data/models/condicion_parcela.dart';

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

const _nombresMes = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

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
      cultivo: provider.recomendaciones.first.nombreComun,
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
          if (provider.recomendaciones.length > 1) ...[
            const SizedBox(height: 16),
            _TambienPuedesSembrar(
                cultivos: provider.recomendaciones.skip(1).toList()),
          ],
          const SizedBox(height: 16),
          _SeccionExplicacion(provider: provider),
          const SizedBox(height: 16),

          _BotonesAccion(onGuardar: onGuardar),
          const SizedBox(height: 20),

          _BentoGrid(
            clima: clima,
            condicion: condicion,
            cultivo: cultivo,
            lluviaSiembra: provider.lluviaEnSiembra(cultivo),
          ),
          const SizedBox(height: 20),

          _RecomendacionesPracticas(recomendaciones: cultivo.recomendaciones),
        ],
      ),
    );
  }
}

class _TarjetaPrincipal extends StatelessWidget {
  final CultivoRecomendado cultivo;
  final CondicionParcela? condicion;

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
                              cultivo.nombreComun,
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
                  if (condicion!.humedad != null) ...[
                    const SizedBox(height: 8),
                    _BadgeRazon(humedad: condicion!.humedad!),
                  ],
                ] else ...[
                  const SizedBox(height: 12),
                  const _BannerSinFoto(),
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
  final CondicionParcela condicion;
  const _BadgeParcela({required this.condicion});

  @override
  Widget build(BuildContext context) {
    final deFoto = condicion.humedadDeLaFoto;
    final (label, color, bg, icon) = switch (condicion.humedad) {
      'seca' => (
          deFoto ? 'Tierra seca ☀️' : 'Sin lluvia reciente ☀️',
          const Color(0xFFE65100),
          const Color(0xFFFFF3E0),
          Icons.wb_sunny_rounded,
        ),
      'humeda' || 'encharcada' => (
          deFoto
              ? (condicion.humedad == 'encharcada'
                  ? 'Tierra encharcada 🌧️'
                  : 'Tierra húmeda 🌧️')
              : 'Llovió esta semana 🌧️',
          const Color(0xFF1565C0),
          const Color(0xFFE3F2FD),
          Icons.water_drop_rounded,
        ),
      _ => (
          'Humedad sin determinar',
          _kOnSurfaceVariant,
          _kSurfaceContainer,
          Icons.help_outline_rounded,
        ),
    };

    final cobertura = switch (condicion.coberturaVegetal) {
      'total' => '🌿 Con plantas',
      'parcial' => '🌱 Algunas plantas',
      'nula' => '🟫 Tierra sin plantas',
      _ => null,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(label: label, color: color, bg: bg, icon: icon),
        if (cobertura != null)
          _Chip(
            label: cobertura,
            color: _kSecondary,
            bg: const Color(0xFFE8F5E9),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
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
    );
  }
}

class _BadgeRazon extends StatelessWidget {
  final String humedad;
  const _BadgeRazon({required this.humedad});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = humedad == 'seca'
        ? (
            '✓ Priorizamos cultivos que aguantan la sequía',
            const Color(0xFFE65100),
            const Color(0xFFFFF3E0),
          )
        : (
            '✓ Priorizamos cultivos que aprovechan la humedad',
            const Color(0xFF1565C0),
            const Color(0xFFE3F2FD),
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _TambienPuedesSembrar extends StatelessWidget {
  final List<CultivoRecomendado> cultivos;
  const _TambienPuedesSembrar({required this.cultivos});

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'También puedes sembrar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kOnSurface,
            ),
          ),
          for (final (i, c) in cultivos.indexed) ...[
            Divider(height: 16, color: Colors.grey.shade200),
            Row(
              children: [
                Text(_emojiCultivo(c.cultivo),
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${i + 2}  ${c.nombreComun}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _kOnSurface,
                        ),
                      ),
                      Text(
                        'Siembra: ${c.mesesSiembra}',
                        style: const TextStyle(
                            fontSize: 12, color: _kOnSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SeccionExplicacion extends StatelessWidget {
  final AppProvider provider;
  const _SeccionExplicacion({required this.provider});

  static String _nombreModelo(String proveedor) =>
      proveedor == 'gemini' ? 'Gemma 4 26B' : 'Gemma 4 local';

  @override
  Widget build(BuildContext context) {
    final explicacion = provider.explicacion;
    final condicion = provider.condicionParcela;

    // Si falló la explicación y no hay análisis que etiquetar, no se muestra nada
    if (!provider.cargandoExplicacion && explicacion == null && condicion == null) {
      return const SizedBox.shrink();
    }

    final etiquetas = [
      if (condicion != null) condicion.etiquetaModelo,
      if (explicacion != null)
        'Explicado con ${_nombreModelo(explicacion.proveedor)}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.cargandoExplicacion)
          const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kPrimary),
              ),
              SizedBox(width: 10),
              Text(
                'Preparando explicación…',
                style: TextStyle(fontSize: 13, color: _kOnSurfaceVariant),
              ),
            ],
          )
        else if (explicacion != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kOutlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 18, color: _kPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    explicacion.texto,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _kOnSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (etiquetas.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            etiquetas.join(' · '),
            style: const TextStyle(fontSize: 11, color: _kOutline),
          ),
        ],
      ],
    );
  }
}

class _BannerSinFoto extends StatelessWidget {
  const _BannerSinFoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0DDD8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.add_a_photo_outlined, size: 16, color: Color(0xFF737977)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Toma una foto de tu parcela para recomendaciones más precisas',
              style: TextStyle(fontSize: 12, color: Color(0xFF737977)),
            ),
          ),
        ],
      ),
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
  final CondicionParcela? condicion;
  final CultivoRecomendado cultivo;
  final double? lluviaSiembra;

  const _BentoGrid({
    required this.clima,
    required this.condicion,
    required this.cultivo,
    required this.lluviaSiembra,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TarjetaCondicionSuelo(condicion: condicion)),
        const SizedBox(width: 12),
        Expanded(
          child: _TarjetaLluvia(
            clima: clima,
            cultivo: cultivo,
            lluviaSiembra: lluviaSiembra,
          ),
        ),
      ],
    );
  }
}

class _TarjetaCondicionSuelo extends StatelessWidget {
  final CondicionParcela? condicion;

  const _TarjetaCondicionSuelo({required this.condicion});

  static String _humedad(CondicionParcela? c) {
    final h = c?.humedad;
    if (h == null) return 'Sin dato';
    final valor = switch (h) {
      'seca' => 'Seca',
      'encharcada' => 'Encharcada',
      _ => 'Húmeda',
    };
    return c!.humedadDeLaFoto ? '$valor (foto)' : '$valor (tú)';
  }

  static String _cobertura(String? cobertura) => switch (cobertura) {
        'total' => 'Total',
        'parcial' => 'Parcial',
        'nula' => 'Sin plantas',
        _ => 'Sin dato',
      };

  static String _pendiente(String? pendiente) => switch (pendiente) {
        'plana' => 'Plana',
        'moderada' => 'Moderada',
        'fuerte' => 'Fuerte',
        _ => 'Sin dato',
      };

  @override
  Widget build(BuildContext context) {

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
            icon: Icons.water_drop_rounded,
            label: 'Humedad',
            valor: _humedad(condicion),
            colorValor: _kOnSecondaryContainer,
            bgValor: _kSecondaryFixed,
          ),
          const SizedBox(height: 8),
          _FilaInfo(
            icon: Icons.grass_rounded,
            label: 'Cobertura',
            valor: _cobertura(condicion?.coberturaVegetal),
            colorValor: _kOnSurface,
            bgValor: _kSurfaceContainer,
          ),
          const SizedBox(height: 8),
          _FilaInfo(
            icon: Icons.terrain_rounded,
            label: 'Pendiente',
            valor: _pendiente(condicion?.pendiente),
            colorValor: _kOnTertiaryFixedVariant,
            bgValor: _kTertiaryFixed,
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

  // Etiqueta arriba y valor abajo: la tarjeta mide media pantalla y en una sola
  // fila el valor dejaba a la etiqueta sin espacio ("Humeda d")
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: _kOnSurfaceVariant),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _kOnSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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

/// Lluvia histórica real (promedio 2018-2023) del mes actual y de los meses
/// de siembra. Sin pronóstico: no tenemos datos de pronóstico.
class _TarjetaLluvia extends StatelessWidget {
  final ClimaMes? clima;
  final CultivoRecomendado cultivo;
  final double? lluviaSiembra;

  const _TarjetaLluvia({
    required this.clima,
    required this.cultivo,
    required this.lluviaSiembra,
  });

  @override
  Widget build(BuildContext context) {
    final mes = _nombresMes[DateTime.now().month - 1];

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
              Icon(Icons.water_drop_rounded, color: _kSecondary, size: 18),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Lluvia histórica',
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
          if (clima != null)
            _DatoLluvia(
              titulo: 'En $mes',
              mm: clima!.precipitacionMensual,
              detalle: '${clima!.tempMedia.toStringAsFixed(0)} °C promedio',
            ),
          if (lluviaSiembra != null) ...[
            const SizedBox(height: 10),
            _DatoLluvia(
              titulo: 'Al sembrar (${cultivo.mesesSiembra.toLowerCase()})',
              mm: lluviaSiembra!,
            ),
          ],
          if (clima == null && lluviaSiembra == null)
            const Text(
              'Sin datos de clima',
              style: TextStyle(fontSize: 12, color: _kOnSurfaceVariant),
            ),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.history_rounded, size: 10, color: _kOnSurfaceVariant),
              SizedBox(width: 3),
              Flexible(
                child: Text(
                  'Datos históricos 2018-2023 (promedio por mes)',
                  style: TextStyle(fontSize: 9, color: _kOnSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatoLluvia extends StatelessWidget {
  final String titulo;
  final double mm;
  final String? detalle;

  const _DatoLluvia({required this.titulo, required this.mm, this.detalle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 11, color: _kOnSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: mm.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kOnSurface,
                ),
              ),
              const TextSpan(
                text: ' mm/mes',
                style: TextStyle(fontSize: 11, color: _kOnSurfaceVariant),
              ),
            ],
          ),
        ),
        if (detalle != null)
          Text(
            detalle!,
            style: const TextStyle(fontSize: 10, color: _kOnSurfaceVariant),
          ),
      ],
    );
  }
}

/// Consejos reales del CSV (columna "recomendaciones"). Si un cultivo no
/// tiene, la sección no aparece: no se rellena con otra columna.
class _RecomendacionesPracticas extends StatelessWidget {
  final List<String> recomendaciones;
  const _RecomendacionesPracticas({required this.recomendaciones});

  @override
  Widget build(BuildContext context) {
    if (recomendaciones.isEmpty) return const SizedBox.shrink();

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
        for (final r in recomendaciones)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kOutlineVariant, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: _kPrimaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.agriculture_rounded,
                        color: Color(0xFF274e3d), size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      r,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _kOnSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

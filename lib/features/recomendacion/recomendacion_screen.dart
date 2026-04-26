import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/cultivo_recomendado.dart';
import '../../ml/image_analyzer.dart';

const _meses = [
  '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const _emojiCultivo = {
  'Maíz': '🌽', 'maíz': '🌽', 'maiz': '🌽',
  'Frijol': '🫘', 'frijol': '🫘',
  'Chile': '🌶️', 'chile': '🌶️',
  'Tomate': '🍅', 'tomate': '🍅',
  'Quelite': '🥬', 'quelite': '🥬',
  'Durazno': '🍑', 'durazno': '🍑',
  'Manzana': '🍎', 'manzana': '🍎',
  'Trigo': '🌾', 'trigo': '🌾',
  'Café': '☕', 'cafe': '☕',
  'Aguacate': '🥑', 'aguacate': '🥑',
  'Calabaza': '🎃', 'calabaza': '🎃',
  'Papa': '🥔', 'papa': '🥔',
  'Zanahoria': '🥕', 'zanahoria': '🥕',
  'Epazote': '🌿', 'epazote': '🌿',
};

String _emoji(String cultivo) {
  for (final entry in _emojiCultivo.entries) {
    if (cultivo.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }
  return '🌱';
}

Color _colorScore(int score) {
  if (score >= 90) return const Color(0xFF2D6A4F);
  if (score >= 75) return const Color(0xFF52B788);
  if (score >= 60) return const Color(0xFFE9C46A);
  return Colors.grey;
}

String _etiquetaScore(int score) {
  if (score >= 90) return 'Excelente';
  if (score >= 75) return 'Bueno';
  if (score >= 60) return 'Regular';
  return 'Bajo';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final municipio = provider.municipioSeleccionado ?? 'tu municipio';
    final mes = DateTime.now().month;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/camara'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Historial',
            onPressed: () => context.go('/historial'),
          ),
        ],
      ),
      body: provider.cargandoRecomendacion
          ? _EstadoCargando()
          : provider.recomendaciones.isEmpty
              ? _SinDatos(municipio: municipio)
              : _ContenidoRecomendacion(
                  municipio: municipio,
                  mes: mes,
                  recomendaciones: provider.recomendaciones,
                  clima: provider.climaActual,
                  condicion: provider.condicionParcela,
                ),
    );
  }
}

class _EstadoCargando extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.verde),
          SizedBox(height: 20),
          Text('Consultando datos del cultivo...',
              style: TextStyle(fontSize: 16, color: AppTheme.textoSecundario)),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textoPrincipal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No se encontraron recomendaciones para este mes.',
              style:
                  TextStyle(fontSize: 14, color: AppTheme.textoSecundario),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.go('/municipio'),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Cambiar municipio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContenidoRecomendacion extends StatelessWidget {
  final String municipio;
  final int mes;
  final List<CultivoRecomendado> recomendaciones;
  final ClimaMes? clima;
  final ParcelCondition? condicion;

  const _ContenidoRecomendacion({
    required this.municipio,
    required this.mes,
    required this.recomendaciones,
    required this.clima,
    required this.condicion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EncabezadoMunicipio(municipio: municipio, mes: mes),
          if (condicion != null) ...[
            const SizedBox(height: 10),
            _BadgeSuelo(condicion: condicion!),
          ],
          if (clima != null) ...[
            const SizedBox(height: 12),
            _TarjetaClima(clima: clima!),
          ],
          const SizedBox(height: 20),
          const Text(
            'Cultivos recomendados',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textoPrincipal),
          ),
          const SizedBox(height: 10),
          ...recomendaciones.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaCultivo(
                    posicion: e.key + 1,
                    cultivo: e.value,
                  ),
                ),
              ),
          const SizedBox(height: 8),
          _BotonesAccion(),
        ],
      ),
    );
  }
}

class _EncabezadoMunicipio extends StatelessWidget {
  final String municipio;
  final int mes;

  const _EncabezadoMunicipio(
      {required this.municipio, required this.mes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.verde,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_rounded, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(municipio,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                  _meses[mes],
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Text('🌽', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}

class _BadgeSuelo extends StatelessWidget {
  final ParcelCondition condicion;
  const _BadgeSuelo({required this.condicion});

  static const _config = {
    'humedo': (
      label: 'Suelo húmedo',
      emoji: '🌧️',
      color: Color(0xFF1565C0),
      bg: Color(0xFFE3F2FD),
    ),
    'seco': (
      label: 'Suelo seco',
      emoji: '☀️',
      color: Color(0xFFE65100),
      bg: Color(0xFFFFF3E0),
    ),
    'fertil': (
      label: 'Tierra fértil',
      emoji: '🌱',
      color: Color(0xFF2D6A4F),
      bg: Color(0xFFE8F5E9),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _config[condicion.soilType] ?? _config['fertil']!;

    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: cfg.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cfg.color.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(cfg.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                cfg.label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cfg.color),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (condicion.hasVegetation)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.verdeClaro.withAlpha(120)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌿', style: TextStyle(fontSize: 14)),
                SizedBox(width: 5),
                Text('Tierra activa',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.verde)),
              ],
            ),
          ),
      ],
    );
  }
}

class _TarjetaClima extends StatelessWidget {
  final ClimaMes clima;
  const _TarjetaClima({required this.clima});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wb_sunny_rounded,
                    color: AppTheme.maizOscuro, size: 18),
                SizedBox(width: 6),
                Text('Clima este mes',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textoPrincipal)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DatoClima(
                    icono: '🌡️',
                    valor: '${clima.tempMedia.toStringAsFixed(1)}°C',
                    etiqueta: 'Temp. media'),
                _DatoClima(
                    icono: '🌧️',
                    valor: '${clima.precipitacion.toStringAsFixed(1)} mm',
                    etiqueta: 'Lluvia'),
                _DatoClima(
                    icono: '💧',
                    valor: '${clima.humedad.toStringAsFixed(0)}%',
                    etiqueta: 'Humedad'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatoClima extends StatelessWidget {
  final String icono;
  final String valor;
  final String etiqueta;

  const _DatoClima(
      {required this.icono, required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icono, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 2),
        Text(valor,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textoPrincipal)),
        Text(etiqueta,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textoSecundario)),
      ],
    );
  }
}

class _TarjetaCultivo extends StatelessWidget {
  final int posicion;
  final CultivoRecomendado cultivo;

  const _TarjetaCultivo(
      {required this.posicion, required this.cultivo});

  @override
  Widget build(BuildContext context) {
    final color = _colorScore(cultivo.score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: posición + emoji + nombre + score
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: posicion == 1 ? AppTheme.maiz : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('$posicion',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: posicion == 1
                                ? AppTheme.verde
                                : AppTheme.textoSecundario)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(_emoji(cultivo.cultivo),
                    style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cultivo.cultivo,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textoPrincipal),
                  ),
                ),
                // Badge de score
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Text(
                    '${cultivo.score} · ${_etiquetaScore(cultivo.score)}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ),
              ],
            ),

            // Barra de score
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: cultivo.score / 100,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),

            const SizedBox(height: 12),
            // Siembra y cosecha
            Row(
              children: [
                Expanded(
                  child: _InfoFecha(
                    icono: Icons.agriculture_rounded,
                    etiqueta: 'Siembra',
                    valor: cultivo.mesesSiembra,
                    color: AppTheme.verde,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoFecha(
                    icono: Icons.grass_rounded,
                    etiqueta: 'Cosecha',
                    valor: cultivo.mesesCosecha,
                    color: AppTheme.tierra,
                  ),
                ),
              ],
            ),

            if (cultivo.notas.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppTheme.textoSecundario),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cultivo.notas,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textoSecundario,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoFecha extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color color;

  const _InfoFecha({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 14, color: color),
              const SizedBox(width: 4),
              Text(etiqueta,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(valor,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textoPrincipal)),
        ],
      ),
    );
  }
}

class _BotonesAccion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go('/camara'),
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Nueva consulta'),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => context.go('/historial'),
          icon: const Icon(Icons.history_rounded),
          label: const Text('Ver historial'),
          style: TextButton.styleFrom(
              foregroundColor: AppTheme.textoSecundario),
        ),
      ],
    );
  }
}

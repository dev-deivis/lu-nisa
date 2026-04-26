import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';

// Datos mock de recomendaciones por cultivo
const List<Map<String, dynamic>> _cultivos = [
  {
    'nombre': 'Maíz criollo',
    'emoji': '🌽',
    'fechaSiembra': 'Mayo – Junio',
    'diasCosecha': 120,
    'temperatura': '14–22°C',
    'lluvia': '600–800 mm',
    'descripcion':
        'El maíz criollo de la Sierra Norte es resistente a la altura y las heladas tardías. Ideal para terrenos con pendiente.',
    'consejos': [
      'Preparar terreno en Marzo–Abril',
      'Sembrar en curvas de nivel',
      'Fertilizar con composta local',
    ],
  },
  {
    'nombre': 'Frijol negro',
    'emoji': '🫘',
    'fechaSiembra': 'Junio – Julio',
    'diasCosecha': 90,
    'temperatura': '15–24°C',
    'lluvia': '400–700 mm',
    'descripcion':
        'El frijol negro es cultivo complementario al maíz en el sistema de milpa. Fija nitrógeno en el suelo.',
    'consejos': [
      'Sembrar asociado con maíz',
      'Evitar encharcamiento',
      'Deshierbar a los 30 días',
    ],
  },
  {
    'nombre': 'Chile de agua',
    'emoji': '🌶️',
    'fechaSiembra': 'Abril – Mayo',
    'diasCosecha': 100,
    'temperatura': '16–26°C',
    'lluvia': '500–700 mm',
    'descripcion':
        'Variedad local de chile adaptada a las condiciones de la Sierra. Alta demanda en mercados regionales.',
    'consejos': [
      'Trasplantar plántula de vivero',
      'Riego por goteo si disponible',
      'Controlar plagas con extracto de ajo',
    ],
  },
  {
    'nombre': 'Quelite / Verdolaga',
    'emoji': '🥬',
    'fechaSiembra': 'Todo el año',
    'diasCosecha': 45,
    'temperatura': '12–20°C',
    'lluvia': '300–600 mm',
    'descripcion':
        'Planta silvestre con gran valor nutricional. Crece naturalmente en milpas y bordos de la Sierra.',
    'consejos': [
      'No requiere preparación especial',
      'Recolectar antes de que florezca',
      'Conservar humedad del suelo',
    ],
  },
];

Map<String, dynamic> _getMockRecomendacion(String municipio) {
  // Asigna un cultivo determinista según el municipio (mock)
  final indice = municipio.length % _cultivos.length;
  return _cultivos[indice];
}

class RecomendacionScreen extends StatefulWidget {
  const RecomendacionScreen({super.key});

  @override
  State<RecomendacionScreen> createState() => _RecomendacionScreenState();
}

class _RecomendacionScreenState extends State<RecomendacionScreen> {
  @override
  void initState() {
    super.initState();
    _guardarConsulta();
  }

  void _guardarConsulta() {
    final provider = context.read<AppProvider>();
    final municipio =
        provider.municipioSeleccionado ?? 'Municipio desconocido';
    final cultivo = _getMockRecomendacion(municipio);
    provider.agregarConsulta(
      Consulta(
        municipio: municipio,
        cultivo: cultivo['nombre'] as String,
        fechaSiembra: cultivo['fechaSiembra'] as String,
        fechaConsulta: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final municipio =
        context.watch<AppProvider>().municipioSeleccionado ?? 'tu municipio';
    final cultivo = _getMockRecomendacion(municipio);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TarjetaCultivoPrincipal(cultivo: cultivo, municipio: municipio),
            const SizedBox(height: 16),
            _TarjetaCondicionesClimaticas(cultivo: cultivo),
            const SizedBox(height: 16),
            _TarjetaConsejos(consejos: cultivo['consejos'] as List),
            const SizedBox(height: 24),
            _BotonesAccion(),
          ],
        ),
      ),
    );
  }
}

class _TarjetaCultivoPrincipal extends StatelessWidget {
  final Map<String, dynamic> cultivo;
  final String municipio;

  const _TarjetaCultivoPrincipal(
      {required this.cultivo, required this.municipio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.verde,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(cultivo['emoji'] as String,
              style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            cultivo['nombre'] as String,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Recomendado para $municipio',
            style:
                const TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.maiz,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month_rounded,
                    color: AppTheme.verde, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Siembra: ${cultivo['fechaSiembra']}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.verde),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            cultivo['descripcion'] as String,
            style: const TextStyle(
                fontSize: 14, color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TarjetaCondicionesClimaticas extends StatelessWidget {
  final Map<String, dynamic> cultivo;
  const _TarjetaCondicionesClimaticas({required this.cultivo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.thermostat_rounded,
                    color: AppTheme.tierra, size: 22),
                SizedBox(width: 8),
                Text('Condiciones óptimas',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textoPrincipal)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _IndicadorClimatico(
                    icono: '🌡️',
                    etiqueta: 'Temperatura',
                    valor: cultivo['temperatura'] as String,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IndicadorClimatico(
                    icono: '🌧️',
                    etiqueta: 'Lluvia anual',
                    valor: cultivo['lluvia'] as String,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IndicadorClimatico(
                    icono: '📅',
                    etiqueta: 'Días cosecha',
                    valor: '${cultivo['diasCosecha']} días',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicadorClimatico extends StatelessWidget {
  final String icono;
  final String etiqueta;
  final String valor;

  const _IndicadorClimatico(
      {required this.icono, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.fondoCalido,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(icono, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textoPrincipal),
            textAlign: TextAlign.center,
          ),
          Text(
            etiqueta,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textoSecundario),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TarjetaConsejos extends StatelessWidget {
  final List consejos;
  const _TarjetaConsejos({required this.consejos});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tips_and_updates_rounded,
                    color: AppTheme.maizOscuro, size: 22),
                SizedBox(width: 8),
                Text('Consejos de cultivo',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textoPrincipal)),
              ],
            ),
            const SizedBox(height: 12),
            ...consejos.map(
              (consejo) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppTheme.verdeClaro, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        consejo as String,
                        style: const TextStyle(
                            fontSize: 15, color: AppTheme.textoPrincipal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.go('/historial'),
          icon: const Icon(Icons.history_rounded),
          label: const Text('Ver historial'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.textoSecundario),
        ),
      ],
    );
  }
}

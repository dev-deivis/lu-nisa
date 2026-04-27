import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';

// Paleta del diseño HTML
const _kPrimary = Color(0xFF012d1d);
const _kSecondary = Color(0xFF1f6d1a);
const _kSecondaryContainer = Color(0xFFa4f792);
const _kBackground = Color(0xFFfcf9f4);
const _kSurface = Color(0xFFffffff);
const _kOnSurface = Color(0xFF1c1c19);
const _kOnSurfaceVariant = Color(0xFF414844);
const _kOutlineVariant = Color(0xFFc1c8c2);
const _kSurfaceTint = Color(0xFF3f6653);
const _kSecondaryFixed = Color(0xFFa4f792);
const _kTertiaryFixed = Color(0xFFffdcc1);
const _kPrimaryFixed = Color(0xFFc1ecd4);

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

Color _bgIconCultivo(String cultivo) {
  final c = cultivo.toLowerCase();
  if (c.contains('maíz') || c.contains('maiz') || c.contains('frijol')) {
    return _kSecondaryFixed;
  }
  if (c.contains('café') || c.contains('durazno') || c.contains('manzana')) {
    return _kTertiaryFixed;
  }
  return _kPrimaryFixed;
}

String _formatearFecha(DateTime fecha) {
  const meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
}

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String? _filtroActivo;

  @override
  Widget build(BuildContext context) {
    final historial = context.watch<AppProvider>().historial;

    final cultivosUnicos =
        historial.map((c) => c.cultivo).toSet().toList();

    final consultasFiltradas = _filtroActivo == null
        ? historial.toList()
        : historial.where((c) => c.cultivo == _filtroActivo).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/recomendacion');
      },
      child: Scaffold(
        backgroundColor: _kBackground,
        appBar: const _LunisaAppBar(),
        body: historial.isEmpty
            ? const _HistorialVacio()
            : _ContenidoHistorial(
                consultas: consultasFiltradas,
                cultivosUnicos: cultivosUnicos,
                filtroActivo: _filtroActivo,
                onFiltroChanged: (f) => setState(() => _filtroActivo = f),
              ),
      ),
    );
  }
}

class _LunisaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LunisaAppBar();

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
        icon: const Icon(Icons.menu_rounded, color: _kOnSurfaceVariant),
        onPressed: () {},
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, color: _kPrimary, size: 22),
          SizedBox(width: 8),
          Text(
            'Lu nisa',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _kPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: _kOutlineVariant,
            child:
                const Icon(Icons.person_rounded, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}

class _HistorialVacio extends StatelessWidget {
  const _HistorialVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _kSecondaryContainer.withAlpha(102),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded,
                  size: 48, color: _kSecondary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin análisis aún',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kOnSurface,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tus recomendaciones de cultivo aparecerán aquí cuando hagas una consulta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _kOnSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/municipio'),
              style: FilledButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              icon: const Icon(Icons.eco_rounded),
              label: const Text(
                'Hacer consulta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContenidoHistorial extends StatelessWidget {
  final List<Consulta> consultas;
  final List<String> cultivosUnicos;
  final String? filtroActivo;
  final ValueChanged<String?> onFiltroChanged;

  const _ContenidoHistorial({
    required this.consultas,
    required this.cultivosUnicos,
    required this.filtroActivo,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis Previos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _kPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Revisa el registro de tus cultivos diagnosticados.',
                  style: TextStyle(
                    fontSize: 15,
                    color: _kOnSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Chips de filtro
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _ChipFiltro(
                  label: 'Todos',
                  icon: Icons.calendar_month_rounded,
                  activo: filtroActivo == null,
                  onTap: () => onFiltroChanged(null),
                ),
                ...cultivosUnicos.map((cultivo) => _ChipFiltro(
                      label: cultivo.split(' ').first,
                      icon: Icons.eco_rounded,
                      activo: filtroActivo == cultivo,
                      onTap: () => onFiltroChanged(
                          filtroActivo == cultivo ? null : cultivo),
                    )),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Lista de tarjetas
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          sliver: SliverList.separated(
            itemCount: consultas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                _TarjetaConsulta(consulta: consultas[i]),
          ),
        ),
      ],
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool activo;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.label,
    required this.icon,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: activo ? _kSurfaceTint : _kSurface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: activo ? _kSurfaceTint : _kOutlineVariant,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: activo ? Colors.white : _kOnSurface),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: activo ? Colors.white : _kOnSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaConsulta extends StatelessWidget {
  final Consulta consulta;
  const _TarjetaConsulta({required this.consulta});

  @override
  Widget build(BuildContext context) {
    final bg = _bgIconCultivo(consulta.cultivo);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Center(
              child: Text(
                _emojiCultivo(consulta.cultivo),
                style: const TextStyle(fontSize: 24),
              ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _kOnSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 13, color: _kOnSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _formatearFecha(consulta.fechaConsulta),
                      style: const TextStyle(
                          fontSize: 12, color: _kOnSurfaceVariant),
                    ),
                    const SizedBox(width: 6),
                    const Text('•',
                        style: TextStyle(color: _kOutlineVariant)),
                    const SizedBox(width: 6),
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: _kOnSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        consulta.municipio,
                        style: const TextStyle(
                            fontSize: 12, color: _kOnSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: _kOnSurfaceVariant, size: 22),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/municipios_data.dart';
import '../../core/providers/app_provider.dart';

class MunicipioScreen extends StatefulWidget {
  const MunicipioScreen({super.key});

  @override
  State<MunicipioScreen> createState() => _MunicipioScreenState();
}

class _MunicipioScreenState extends State<MunicipioScreen> {
  final TextEditingController _buscarCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  Map<String, List<String>> get _filtrado {
    if (_query.isEmpty) return municipiosPorDistrito;
    final q = _query.toLowerCase();
    final result = <String, List<String>>{};
    for (final entry in municipiosPorDistrito.entries) {
      final coincidencias = entry.value
          .where((m) => m.toLowerCase().contains(q))
          .toList();
      if (coincidencias.isNotEmpty) {
        result[entry.key] = coincidencias;
      }
    }
    return result;
  }

  void _seleccionar(BuildContext context, String municipio, String distrito) {
    context.read<AppProvider>().seleccionarMunicipio(municipio, distrito);
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    context.go(from == 'inicio' ? '/inicio' : '/camara');
  }

  @override
  Widget build(BuildContext context) {
    final filtrado = _filtrado;
    final totalVisible =
        filtrado.values.fold(0, (sum, lista) => sum + lista.length);
    final from = GoRouterState.of(context).uri.queryParameters['from'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu municipio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(from == 'inicio' ? '/inicio' : '/'),
        ),
      ),
      body: Column(
        children: [
          _BarraBusqueda(
            controller: _buscarCtrl,
            onChanged: (v) => setState(() => _query = v),
          ),
          _ContadorResultados(total: totalVisible),
          Expanded(
            child: totalVisible == 0
                ? _SinResultados(query: _query)
                : _ListaMunicipios(
                    filtrado: filtrado,
                    onSeleccionar: (municipio, distrito) =>
                        _seleccionar(context, municipio, distrito),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BarraBusqueda extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _BarraBusqueda(
      {required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.verde,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Buscar municipio...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.verde),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _ContadorResultados extends StatelessWidget {
  final int total;
  const _ContadorResultados({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.fondoCalido,
      child: Row(
        children: [
          const Icon(Icons.place_rounded, size: 16, color: AppTheme.textoSecundario),
          const SizedBox(width: 6),
          Text(
            '$total municipios',
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textoSecundario,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ListaMunicipios extends StatelessWidget {
  final Map<String, List<String>> filtrado;
  final void Function(String municipio, String distrito) onSeleccionar;

  const _ListaMunicipios(
      {required this.filtrado, required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
    final distritos = filtrado.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: distritos.length,
      itemBuilder: (context, i) {
        final distrito = distritos[i];
        final municipios = filtrado[distrito]!;
        return _SeccionDistrito(
          distrito: distrito,
          municipios: municipios,
          onSeleccionar: onSeleccionar,
        );
      },
    );
  }
}

class _SeccionDistrito extends StatelessWidget {
  final String distrito;
  final List<String> municipios;
  final void Function(String municipio, String distrito) onSeleccionar;

  const _SeccionDistrito({
    required this.distrito,
    required this.municipios,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final icono = iconoDistrito[distrito] ?? '📍';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.verdeMuy,
          child: Row(
            children: [
              Text(icono, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Distrito $distrito',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.verde,
                ),
              ),
              const Spacer(),
              Text(
                '${municipios.length}',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.verdeClaro),
              ),
            ],
          ),
        ),
        ...municipios.map(
          (municipio) => _TileMunicipio(
            municipio: municipio,
            onTap: () => onSeleccionar(municipio, distrito),
          ),
        ),
      ],
    );
  }
}

class _TileMunicipio extends StatelessWidget {
  final String municipio;
  final VoidCallback onTap;

  const _TileMunicipio({required this.municipio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(color: Colors.grey.shade200, width: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 20, color: AppTheme.tierra),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                municipio,
                style: const TextStyle(
                    fontSize: 16, color: AppTheme.textoPrincipal),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textoSecundario),
          ],
        ),
      ),
    );
  }
}

class _SinResultados extends StatelessWidget {
  final String query;
  const _SinResultados({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌾', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'No se encontró "$query"',
            style: const TextStyle(
                fontSize: 16, color: AppTheme.textoSecundario),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

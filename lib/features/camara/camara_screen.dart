import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../ml/image_analyzer.dart';

class CamaraScreen extends StatefulWidget {
  const CamaraScreen({super.key});

  @override
  State<CamaraScreen> createState() => _CamaraScreenState();
}

class _CamaraScreenState extends State<CamaraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imagen;
  bool _cargando = false;
  String _estadoAnalisis = 'Analizando imagen...';

  Future<void> _tomarFoto() async {
    final foto = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (foto != null) setState(() => _imagen = foto);
  }

  Future<void> _seleccionarGaleria() async {
    final foto = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (foto != null) setState(() => _imagen = foto);
  }

  Future<void> _analizarCultivo() async {
    if (_imagen == null) return;
    setState(() {
      _cargando = true;
      _estadoAnalisis = 'Analizando imagen...';
    });

    try {
      setState(() => _estadoAnalisis = 'Detectando vegetación y suelo...');
      final condicion = await ImageAnalyzer.analyzeParcel(_imagen!.path);

      if (!mounted) return;
      context.read<AppProvider>().setCondicionParcela(condicion);
      context.go('/recomendacion');
    } catch (_) {
      if (!mounted) return;
      // Si el análisis falla, navega sin condición (usa datos del JSON puro)
      context.read<AppProvider>().setCondicionParcela(ParcelCondition.sinFoto);
      context.go('/recomendacion');
    }
  }

  @override
  Widget build(BuildContext context) {
    final municipio =
        context.watch<AppProvider>().municipioSeleccionado ?? 'tu municipio';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto del cultivo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed:
              _cargando ? null : () => context.go('/municipio'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => context.go('/perfil'),
              borderRadius: BorderRadius.circular(17),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoMunicipio(municipio: municipio),
              const SizedBox(height: 20),
              Expanded(
                child: _cargando
                    ? _EstadoAnalisis(mensaje: _estadoAnalisis)
                    : _AreaFoto(imagen: _imagen),
              ),
              const SizedBox(height: 20),
              if (!_cargando)
                _BotonesFoto(
                  onCamara: _tomarFoto,
                  onGaleria: _seleccionarGaleria,
                ),
              if (_imagen != null && !_cargando) ...[
                const SizedBox(height: 16),
                _BotonAnalizar(onTap: _analizarCultivo),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoMunicipio extends StatelessWidget {
  final String municipio;
  const _InfoMunicipio({required this.municipio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.verdeMuy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_rounded, color: AppTheme.verde, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Municipio seleccionado',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textoSecundario)),
                Text(
                  municipio,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.verde),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoAnalisis extends StatelessWidget {
  final String mensaje;
  const _EstadoAnalisis({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.verdeMuy.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.verde),
          const SizedBox(height: 20),
          Text(
            mensaje,
            style: const TextStyle(
                fontSize: 16,
                color: AppTheme.verde,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'ML Kit · análisis local',
            style:
                TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
          ),
        ],
      ),
    );
  }
}

class _AreaFoto extends StatelessWidget {
  final XFile? imagen;
  const _AreaFoto({this.imagen});

  @override
  Widget build(BuildContext context) {
    if (imagen != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(imagen!.path),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Toma o selecciona una foto\nde tu cultivo o terreno',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _BotonesFoto extends StatelessWidget {
  final VoidCallback onCamara;
  final VoidCallback onGaleria;

  const _BotonesFoto({required this.onCamara, required this.onGaleria});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGaleria,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Galería'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              foregroundColor: AppTheme.verde,
              side: const BorderSide(color: AppTheme.verde, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onCamara,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Cámara'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 52),
              backgroundColor: AppTheme.verde,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotonAnalizar extends StatelessWidget {
  final Future<void> Function() onTap;

  const _BotonAnalizar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => onTap(),
        icon: const Icon(Icons.biotech_rounded),
        label: const Text('Analizar y ver recomendación'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.tierra,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

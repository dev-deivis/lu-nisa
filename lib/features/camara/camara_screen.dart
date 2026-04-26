import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';

class CamaraScreen extends StatefulWidget {
  const CamaraScreen({super.key});

  @override
  State<CamaraScreen> createState() => _CamaraScreenState();
}

class _CamaraScreenState extends State<CamaraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imagen;
  bool _cargando = false;

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

  void _analizarCultivo() {
    setState(() => _cargando = true);
    // Simula procesamiento breve antes de navegar
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) context.go('/recomendacion');
    });
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
          onPressed: () => context.go('/municipio'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoMunicipio(municipio: municipio),
              const SizedBox(height: 20),
              Expanded(child: _AreaFoto(imagen: _imagen)),
              const SizedBox(height: 20),
              _BotonesFoto(
                onCamara: _tomarFoto,
                onGaleria: _seleccionarGaleria,
              ),
              if (_imagen != null) ...[
                const SizedBox(height: 16),
                _BotonAnalizar(
                  cargando: _cargando,
                  onTap: _analizarCultivo,
                ),
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
  final bool cargando;
  final VoidCallback onTap;

  const _BotonAnalizar({required this.cargando, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: cargando ? null : onTap,
        icon: cargando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.eco_rounded),
        label: Text(cargando ? 'Analizando...' : 'Ver recomendación'),
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

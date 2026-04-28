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
    if (_imagen == null) {
      // Optional fallback if no image is selected, but the UI allows proceeding or picking.
      // We will open the gallery picker if no image is selected.
      await _seleccionarGaleria();
      if (_imagen == null) return;
    }
    
    setState(() {
      _cargando = true;
    });

    try {
      final condicion = await ImageAnalyzer.analyzeParcel(_imagen!.path);
      
      // Simulate slightly longer loading time so user can appreciate the loading design
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      context.read<AppProvider>().setCondicionParcela(condicion);
      context.go('/recomendacion');
    } catch (_) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 3));
      context.read<AppProvider>().setCondicionParcela(ParcelCondition.sinFoto);
      context.go('/recomendacion');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: _PantallaCarga(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Light cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade300),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF012d1d)),
          onPressed: () {},
        ),
        title: const Text(
          'Lu nisa',
          style: TextStyle(
            color: Color(0xFF012d1d), // Dark green
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => context.go('/perfil'),
              borderRadius: BorderRadius.circular(17),
              child: const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFFc1c8c2),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Análisis de Cultivo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF012d1d),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sube o toma una foto clara del área que deseas analizar. Asegúrate de tener buena iluminación natural.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A4A4A),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _AreaFoto(imagen: _imagen),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _BotonAccion(
                    icon: Icons.camera_alt,
                    text: 'Tomar foto',
                    onTap: _tomarFoto,
                  ),
                  const SizedBox(width: 16),
                  _BotonAccion(
                    icon: Icons.image,
                    text: 'Subir desde\ngalería',
                    onTap: _seleccionarGaleria,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _analizarCultivo,
                  icon: const Icon(Icons.document_scanner_outlined, color: Colors.white),
                  label: const Text(
                    'Procesar imagen',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF012d1d),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaFoto extends StatelessWidget {
  final XFile? imagen;
  const _AreaFoto({this.imagen});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagen != null)
              Image.file(
                File(imagen!.path),
                fit: BoxFit.cover,
              )
            else
              // Placeholder when no image is selected to match the screenshot precisely.
              // Changed to local corn plant (planta de maíz) image for offline usage.
              Image.asset(
                'recursos/maiz.jpg',
                fit: BoxFit.cover,
              ),
            // Overlay gradient for better contrast
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            // Dashed frame with corners
            Padding(
              padding: const EdgeInsets.only(left: 36.0, right: 36.0, top: 24.0, bottom: 12.0),
              child: CustomPaint(
                painter: ScannerOverlayPainter(),
              ),
            ),
            // "Centra la planta aquí" pill
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF012d1d).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Centra la planta aquí',
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Center target icon
            Center(
              child: Icon(
                Icons.center_focus_strong,
                size: 64,
                color: const Color(0xFFB7E4C7).withOpacity(0.9), // light green
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _BotonAccion({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF012d1d), size: 32),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF012d1d),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 30.0;
    
    // Top Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
    
    // Draw dashed lines between corners
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    _drawDashedLine(canvas, const Offset(cornerLength, 0), Offset(size.width - cornerLength, 0), dashPaint);
    _drawDashedLine(canvas, Offset(cornerLength, size.height), Offset(size.width - cornerLength, size.height), dashPaint);
    _drawDashedLine(canvas, const Offset(0, cornerLength), Offset(0, size.height - cornerLength), dashPaint);
    _drawDashedLine(canvas, Offset(size.width, cornerLength), Offset(size.width, size.height - cornerLength), dashPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const int dashWidth = 8;
    const int dashSpace = 6;
    double startX = start.dx;
    double startY = start.dy;
    
    // If line is horizontal
    if (startY == end.dy) {
      while (startX < end.dx) {
        canvas.drawLine(Offset(startX, startY), Offset(startX + dashWidth, startY), paint);
        startX += dashWidth + dashSpace;
      }
    } 
    // If line is vertical
    else if (startX == end.dx) {
      while (startY < end.dy) {
        canvas.drawLine(Offset(startX, startY), Offset(startX, startY + dashWidth), paint);
        startY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PantallaCarga extends StatefulWidget {
  const _PantallaCarga();

  @override
  State<_PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<_PantallaCarga> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE9F5EC), // Very Light green
            Color(0xFFFDFBF7), // Cream
            Color(0xFFFFF3E0), // Very light orange/pinkish
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Circular progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD3EADD).withOpacity(0.5),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle: _controller.value * 2 * 3.141592653589793,
                            child: child,
                          );
                        },
                        child: const CircularProgressIndicator(
                          value: 0.25, // Showing a 1/4 arc
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF012d1d)),
                          backgroundColor: Colors.transparent,
                          strokeWidth: 8,
                        ),
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.energy_savings_leaf, // A good leaf icon
                        size: 40,
                        color: Color(0xFF012d1d),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'Analizando tu\nparcela y condiciones\nclimáticas...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF012d1d),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Consultando el conocimiento de\nla tierra y los pronósticos más\nrecientes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A4A4A),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                // Card with checklist
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _CheckItem(icon: Icons.check_circle, iconColor: const Color(0xFF2D6A4F), text: 'Ubicación leída', isBold: true, textColor: const Color(0xFF012d1d)),
                      const SizedBox(height: 24),
                      _CheckItem(icon: Icons.cloud_sync, iconColor: const Color(0xFF8BA99B), text: 'Clima local', isBold: true, textColor: const Color(0xFF012d1d)),
                      const SizedBox(height: 24),
                      _CheckItem(icon: Icons.eco, iconColor: Colors.grey.shade400, text: 'Generando plan', isBold: true, textColor: Colors.grey.shade500),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final bool isBold;
  final Color textColor;

  const _CheckItem({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.isBold = false,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/location_service.dart';

enum _Estado { buscando, confirmar, fueraRegion, sinSenal, permisoDenegado }

class UbicacionScreen extends StatefulWidget {
  const UbicacionScreen({super.key});

  @override
  State<UbicacionScreen> createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  _Estado _estado = _Estado.buscando;
  String? _municipioDetectado;
  String? _distritoDetectado;

  static const _fondoCalido = Color(0xFFFCF9F4);

  @override
  void initState() {
    super.initState();
    _detectarUbicacion();
  }

  Future<void> _detectarUbicacion() async {
    final permiso = await LocationService.solicitarPermiso();
    if (!mounted) return;

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      setState(() => _estado = _Estado.permisoDenegado);
      return;
    }

    final posicion = await LocationService.obtenerPosicion();
    if (!mounted) return;

    if (posicion == null) {
      setState(() => _estado = _Estado.sinSenal);
      return;
    }

    final resultado = LocationService.detectarMunicipio(
      posicion.latitude,
      posicion.longitude,
    );

    if (!mounted) return;

    if (resultado == null) {
      setState(() => _estado = _Estado.fueraRegion);
      return;
    }

    setState(() {
      _estado = _Estado.confirmar;
      _municipioDetectado = resultado.municipio;
      _distritoDetectado = resultado.distrito;
    });
  }

  void _confirmarMunicipio() {
    context.read<AppProvider>().seleccionarMunicipio(
          _municipioDetectado!,
          _distritoDetectado!,
        );
    context.go('/inicio');
  }

  void _irSelectorMunicipio() {
    context.go('/municipio?from=ubicacion');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoCalido,
      body: SafeArea(
        child: switch (_estado) {
          _Estado.buscando       => _PantallaBuscando(),
          _Estado.confirmar      => _PantallaConfirmar(
              municipio: _municipioDetectado!,
              distrito: _distritoDetectado!,
              onConfirmar: _confirmarMunicipio,
              onCambiar: _irSelectorMunicipio,
            ),
          _Estado.fueraRegion    => _PantallaFueraRegion(
              onSeleccionarMunicipio: _irSelectorMunicipio,
            ),
          _Estado.sinSenal       => _PantallaSinSenal(
              onSeleccionarMunicipio: _irSelectorMunicipio,
            ),
          _Estado.permisoDenegado => _PantallaPermisoDenegado(
              onSeleccionarMunicipio: _irSelectorMunicipio,
            ),
        },
      ),
    );
  }
}

// ─── Spinner de búsqueda ───────────────────────────────────────────────────

class _PantallaBuscando extends StatelessWidget {
  static const _verde = Color(0xFF012D1D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _verde.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: _verde,
                  strokeWidth: 4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Detectando tu\nubicación...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _verde,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esto solo tarda unos segundos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Confirmación de municipio ────────────────────────────────────────────

class _PantallaConfirmar extends StatelessWidget {
  final String municipio;
  final String distrito;
  final VoidCallback onConfirmar;
  final VoidCallback onCambiar;

  static const _verde = Color(0xFF012D1D);

  const _PantallaConfirmar({
    required this.municipio,
    required this.distrito,
    required this.onConfirmar,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _verde.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: _verde, size: 48),
          ),
          const SizedBox(height: 28),
          const Text(
            'Detectamos que estás en',
            style: TextStyle(fontSize: 18, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 10),
          Text(
            municipio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _verde,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Distrito $distrito',
            style: const TextStyle(fontSize: 16, color: Color(0xFF777777)),
          ),
          const SizedBox(height: 10),
          const Text(
            '¿Es correcto?',
            style: TextStyle(fontSize: 18, color: Color(0xFF444444)),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onConfirmar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _verde,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirmar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: onCambiar,
              style: OutlinedButton.styleFrom(
                foregroundColor: _verde,
                side: const BorderSide(color: _verde, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cambiar municipio',
                  style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fuera de la Sierra Norte ─────────────────────────────────────────────

class _PantallaFueraRegion extends StatelessWidget {
  final VoidCallback onSeleccionarMunicipio;

  static const _verde = Color(0xFF012D1D);

  const _PantallaFueraRegion({required this.onSeleccionarMunicipio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore_off_rounded,
                color: Color(0xFFE65100), size: 48),
          ),
          const SizedBox(height: 28),
          const Text(
            'No estás en la Sierra Norte',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _verde,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No te preocupes,',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
          ),
          Text(
            'igual puedes usar Lu-nisa.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: onSeleccionarMunicipio,
              style: ElevatedButton.styleFrom(
                backgroundColor: _verde,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Elige tu municipio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Escoge dónde está tu parcela y luego podrás analizarla con una foto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sin señal GPS ────────────────────────────────────────────────────────

class _PantallaSinSenal extends StatelessWidget {
  final VoidCallback onSeleccionarMunicipio;

  static const _verde = Color(0xFF012D1D);

  const _PantallaSinSenal({required this.onSeleccionarMunicipio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.gps_off_rounded,
                color: Colors.grey.shade500, size: 48),
          ),
          const SizedBox(height: 28),
          const Text(
            'No pudimos detectar tu ubicación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _verde,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Selecciona tu municipio manualmente:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onSeleccionarMunicipio,
              icon: const Icon(Icons.list_rounded, color: Colors.white),
              label: const Text(
                'Seleccionar municipio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _verde,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Permiso denegado ─────────────────────────────────────────────────────

class _PantallaPermisoDenegado extends StatelessWidget {
  final VoidCallback onSeleccionarMunicipio;

  static const _verde = Color(0xFF012D1D);

  const _PantallaPermisoDenegado({required this.onSeleccionarMunicipio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _verde.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_off_rounded,
                color: _verde, size: 48),
          ),
          const SizedBox(height: 28),
          const Text(
            'Lu-nisa necesita acceder a tu ubicación para analizar las condiciones de tu parcela',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _verde,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Puedes seleccionar tu municipio manualmente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onSeleccionarMunicipio,
              icon: const Icon(Icons.list_rounded, color: Colors.white),
              label: const Text(
                'Seleccionar municipio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _verde,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

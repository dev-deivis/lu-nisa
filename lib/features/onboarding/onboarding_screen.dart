import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.verde,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              _CuerpoOnboarding(),
              _BotonComenzar(
                onTap: () => context.go('/municipio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CuerpoOnboarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícono principal
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '🌽',
              style: TextStyle(fontSize: 72),
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Nombre de la app
        const Text(
          'Lu-nisa',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),

        // Subtítulo en español
        const Text(
          'Guía agrícola de la Sierra Norte',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),

        // Subtítulo en zapoteco
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '"Guendaró lu yoo neza"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Zapoteco · Sierra Norte',
          style: TextStyle(fontSize: 12, color: Colors.white54),
        ),
        const SizedBox(height: 40),

        // Características rápidas
        _CaracteristicaItem(
          icono: Icons.wifi_off_rounded,
          texto: 'Funciona sin internet',
        ),
        const SizedBox(height: 12),
        _CaracteristicaItem(
          icono: Icons.location_city_rounded,
          texto: '68 municipios de la Sierra',
        ),
        const SizedBox(height: 12),
        _CaracteristicaItem(
          icono: Icons.eco_rounded,
          texto: 'Recomendaciones de cultivo',
        ),
      ],
    );
  }
}

class _CaracteristicaItem extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _CaracteristicaItem({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icono, color: AppTheme.maiz, size: 22),
        const SizedBox(width: 10),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _BotonComenzar extends StatelessWidget {
  final VoidCallback onTap;

  const _BotonComenzar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.maiz,
              foregroundColor: AppTheme.verde,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Text(
              'Comenzar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Versión 1.0 · Oaxaca, México',
          style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
        ),
      ],
    );
  }
}

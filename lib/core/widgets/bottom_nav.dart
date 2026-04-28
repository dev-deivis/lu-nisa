import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LunisaBottomNav extends StatelessWidget {
  const LunisaBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final currentIndex = switch (path) {
      '/inicio' => 0,
      '/camara' => 1,
      '/historial' => 2,
      _ => 0,
    };

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E2DD), width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                isActive: currentIndex == 0,
                onTap: () => context.go('/inicio'),
              ),
              _NavItem(
                icon: Icons.photo_camera_rounded,
                label: 'Cámara',
                isActive: currentIndex == 1,
                onTap: () => context.go('/camara'),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Historial',
                isActive: currentIndex == 2,
                onTap: () => context.go('/historial'),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                isActive: currentIndex == 3,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? const Color(0xFF012D1D) : const Color(0xFF737977);
    final bgColor =
        isActive ? const Color(0xFFECF5F0) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

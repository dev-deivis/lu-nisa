import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/municipio/municipio_screen.dart';
import 'features/camara/camara_screen.dart';
import 'features/recomendacion/recomendacion_screen.dart';
import 'features/historial/historial_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/municipio',
      builder: (context, state) => const MunicipioScreen(),
    ),
    GoRoute(
      path: '/camara',
      builder: (context, state) => const CamaraScreen(),
    ),
    GoRoute(
      path: '/recomendacion',
      builder: (context, state) => const RecomendacionScreen(),
    ),
    GoRoute(
      path: '/historial',
      builder: (context, state) => const HistorialScreen(),
    ),
  ],
);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const LunisaApp(),
    ),
  );
}

class LunisaApp extends StatelessWidget {
  const LunisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lu-nisa',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

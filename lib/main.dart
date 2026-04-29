import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/inicio/inicio_screen.dart';
import 'features/municipio/municipio_screen.dart';
import 'features/camara/camara_screen.dart';
import 'features/recomendacion/recomendacion_screen.dart';
import 'features/historial/historial_screen.dart';
import 'features/main_screen.dart';
import 'features/perfil/perfil_screen.dart';
import 'features/ubicacion/ubicacion_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/ubicacion',
      builder: (context, state) => const UbicacionScreen(),
    ),
    GoRoute(
      path: '/municipio',
      builder: (context, state) => const MunicipioScreen(),
    ),
    GoRoute(
      path: '/recomendacion',
      builder: (context, state) => const RecomendacionScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inicio',
              builder: (context, state) => const InicioScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/camara',
              builder: (context, state) => const CamaraScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/historial',
              builder: (context, state) => const HistorialScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/perfil',
              builder: (context, state) => const PerfilScreen(),
            ),
          ],
        ),
      ],
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

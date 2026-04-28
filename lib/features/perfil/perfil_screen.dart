import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_provider.dart';

// Paleta del diseño HTML
const _kPrimary = Color(0xFF012d1d);
const _kBackground = Color(0xFFfcf9f4);
const _kSurface = Color(0xFFffffff);
const _kOnSurface = Color(0xFF1c1c19);
const _kOnSurfaceVariant = Color(0xFF414844);
const _kOutlineVariant = Color(0xFFc1c8c2);
const _kTertiaryFixed = Color(0xFFffdcc1);

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String idioma = 'Español';
  bool offlineMode = true;
  bool climaAlertas = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: const _LunisaAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil y Ajustes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _kPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gestiona tu información y preferencias para adaptar la herramienta a tus necesidades locales.',
              style: TextStyle(
                fontSize: 15,
                color: _kOnSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Card Productor Local
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kOutlineVariant, width: 1.0),
              ),
              child: Row(
                children: [
                   Container(
                     width: 64,
                     height: 64,
                     decoration: const BoxDecoration(
                       color: _kTertiaryFixed,
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.park_rounded, color: Color(0xFF7c4a2a), size: 30),
                   ),
                   const SizedBox(width: 16),
                   const Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Productor Local',
                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kOnSurface),
                         ),
                         SizedBox(height: 4),
                         Text(
                           'Sierra Norte de Oaxaca',
                           style: TextStyle(fontSize: 14, color: _kOnSurfaceVariant),
                         ),
                         SizedBox(height: 8),
                         Text(
                           'Editar perfil',
                           style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _kPrimary),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const _SectionTitle(icon: Icons.place_rounded, title: 'Ubicación de Trabajo'),
            const SizedBox(height: 16),
            const _UbicacionForm(),
            
            const SizedBox(height: 32),
            const _SectionTitle(icon: Icons.tune_rounded, title: 'Ajustes Básicos'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kOutlineVariant, width: 1.0),
              ),
              child: Column(
                children: [
                  _ToggleAjuste(
                    icon: Icons.cloud_download_rounded,
                    title: 'Modo sin conexión',
                    subtitle: 'Descarga mapas y datos para usarlos en la parcela sin internet.',
                    value: offlineMode,
                    onChanged: (v) => setState(() => offlineMode = v),
                  ),
                  const Divider(height: 1, color: _kOutlineVariant),
                  _ToggleAjuste(
                    icon: Icons.notifications_active_rounded,
                    title: 'Alertas de clima',
                    subtitle: 'Recibe avisos sobre lluvias fuertes o heladas en tu zona.',
                    value: climaAlertas,
                    onChanged: (v) => setState(() => climaAlertas = v),
                  ),
                  const Divider(height: 1, color: _kOutlineVariant),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.help_outline_rounded, color: _kOnSurfaceVariant, size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Ayuda y Soporte',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _kOnSurface),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: _kOnSurfaceVariant),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFb3261e)),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Color(0xFFb3261e), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFb3261e)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kPrimary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kPrimary),
        ),
      ],
    );
  }
}

class _UbicacionForm extends StatelessWidget {
  const _UbicacionForm();
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final municipio = provider.municipioSeleccionado ?? 'No seleccionado';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Municipio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kOnSurfaceVariant)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kOutlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(municipio, style: const TextStyle(fontSize: 15, color: _kOnSurface)),
                const Icon(Icons.keyboard_arrow_down_rounded, color: _kOnSurfaceVariant),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Comunidad / Paraje (Opcional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kOnSurfaceVariant)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kOutlineVariant),
            ),
            child: const Text('Comunidad no seleccionada', style: TextStyle(fontSize: 15, color: _kOnSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

class _ToggleAjuste extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleAjuste({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _kOnSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kOnSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: _kOnSurfaceVariant, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _kPrimary,
            inactiveThumbColor: _kOutlineVariant,
            inactiveTrackColor: _kSurface,
          ),
        ],
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
      backgroundColor: _kBackground,
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
          child: InkWell(
            onTap: () => context.go('/perfil'),
            borderRadius: BorderRadius.circular(17),
            child: const CircleAvatar(
              radius: 17,
              backgroundColor: _kOutlineVariant,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

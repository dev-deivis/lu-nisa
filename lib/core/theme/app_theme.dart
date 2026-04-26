import 'package:flutter/material.dart';

class AppTheme {
  static const Color verde = Color(0xFF2D6A4F);
  static const Color verdeClaro = Color(0xFF52B788);
  static const Color verdeMuy = Color(0xFFB7E4C7);
  static const Color tierra = Color(0xFF8B5E3C);
  static const Color tierraClaro = Color(0xFFD4A57A);
  static const Color maiz = Color(0xFFE9C46A);
  static const Color maizOscuro = Color(0xFFC9A227);
  static const Color fondoCalido = Color(0xFFF5F0E8);
  static const Color fondoTarjeta = Color(0xFFFFFFFF);
  static const Color textoPrincipal = Color(0xFF1A1A1A);
  static const Color textoSecundario = Color(0xFF555555);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: verde,
          primary: verde,
          secondary: maiz,
          tertiary: tierra,
          surface: fondoCalido,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: fondoCalido,
        appBarTheme: const AppBarTheme(
          backgroundColor: verde,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: textoPrincipal),
          displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textoPrincipal),
          headlineLarge: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textoPrincipal),
          headlineMedium: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textoPrincipal),
          headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textoPrincipal),
          titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textoPrincipal),
          titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textoPrincipal),
          bodyLarge:
              TextStyle(fontSize: 16, color: textoPrincipal, height: 1.5),
          bodyMedium:
              TextStyle(fontSize: 14, color: textoSecundario, height: 1.4),
          labelLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: verde,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 3,
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: verde,
            side: const BorderSide(color: verde, width: 2),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: verde, width: 2),
          ),
          hintStyle: const TextStyle(color: textoSecundario, fontSize: 16),
        ),
        cardTheme: CardThemeData(
          color: fondoTarjeta,
          elevation: 2,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,
          thickness: 1,
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textoPrincipal),
          subtitleTextStyle: TextStyle(fontSize: 14, color: textoSecundario),
        ),
      );
}

import 'package:flutter/material.dart';
import 'brand.dart';

class AppTheme {
  static ThemeData _base(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: Brand.primary,
      brightness: brightness,
      primary: Brand.primary,
      onPrimary: Colors.white,
      secondary: Brand.primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? Brand.background : const Color(0xFFF4F5F7),
      canvasColor: dark ? Brand.background : const Color(0xFFF4F5F7),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? Brand.background : Colors.white,
        foregroundColor: dark ? Brand.text : const Color(0xFF151719),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: dark ? Brand.text : const Color(0xFF151719),
        ),
      ),
      cardTheme: CardTheme(
        color: dark ? Brand.surface : Colors.white,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: dark ? Brand.border : const Color(0xFFE1E5E8)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? Brand.border : const Color(0xFFE1E5E8),
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: dark ? const Color(0xFF0F1113) : Colors.white,
        unselectedIconTheme: IconThemeData(
          color: dark ? const Color(0xFF7D868E) : const Color(0xFF6C737A),
        ),
        unselectedLabelTextStyle: TextStyle(
          color: dark ? const Color(0xFF8A939B) : const Color(0xFF6C737A),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: Brand.primary.withOpacity(dark ? 0.13 : 0.10),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF0F1113) : Colors.white,
        indicatorColor: Brand.primary.withOpacity(dark ? 0.16 : 0.12),
        selectedIconTheme: const IconThemeData(color: Brand.primary),
        selectedLabelTextStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Brand.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF101316) : const Color(0xFFF7F8F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dark ? Brand.border : const Color(0xFFD8DDE2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dark ? Brand.border : const Color(0xFFD8DDE2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Brand.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Brand.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? Brand.text : const Color(0xFF22272B),
          side: BorderSide(color: dark ? Brand.border : const Color(0xFFD6DBE0)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? Brand.surfaceAlt : const Color(0xFFEEF1F3),
        selectedColor: Brand.primary.withOpacity(0.15),
        side: BorderSide(color: dark ? Brand.border : const Color(0xFFD8DDE2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        labelStyle: TextStyle(
          color: dark ? Brand.text : const Color(0xFF2B3136),
          fontWeight: FontWeight.w700,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return Brand.primary;
          return dark ? const Color(0xFF7B838B) : const Color(0xFF9AA1A8);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return Brand.primary.withOpacity(0.25);
          return dark ? const Color(0xFF2A3035) : const Color(0xFFD8DDE2);
        }),
      ),
    );
  }

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);
}

import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF00A87E);
  static const Color primaryDeep = Color(0xFF008F6A);
  static const Color accent = Color(0xFFFFB547);
  static const Color danger = Color(0xFFFF5A5A);
  static const Color info = Color(0xFF5B8DEF);

  // Light palette
  static const Color bgLight = Color(0xFFF7F9F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // Dark palette
  static const Color bgDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF1C2333);
  static const Color cardDarkElevated = Color(0xFF21293A);
  static const Color textPrimaryDark = Color(0xFFE6EDF3);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color borderDark = Color(0xFF30363D);
  static const Color dividerDark = Color(0xFF21262D);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          surface: surfaceLight,
          onSurface: textPrimaryLight,
        ),
        scaffoldBackgroundColor: bgLight,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: bgLight,
          foregroundColor: textPrimaryLight,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimaryLight,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          iconTheme: IconThemeData(color: textPrimaryLight, size: 20),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: cardLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: borderLight, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderLight, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderLight, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: textSecondaryLight, fontSize: 14),
          hintStyle: const TextStyle(color: textSecondaryLight, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        dividerTheme: const DividerThemeData(
          color: dividerLight,
          thickness: 1,
          space: 1,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? primary : Colors.white),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? primary.withOpacity(0.3)
                  : Colors.grey.shade200),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          thumbColor: primary,
          inactiveTrackColor: Color(0xFFE5E7EB),
          trackHeight: 4,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: textPrimaryLight,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primary,
          surface: surfaceDark,
          onSurface: textPrimaryDark,
        ),
        scaffoldBackgroundColor: bgDark,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: bgDark,
          foregroundColor: textPrimaryDark,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimaryDark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          iconTheme: IconThemeData(color: textPrimaryDark, size: 20),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: borderDark, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderDark, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderDark, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: textSecondaryDark, fontSize: 14),
          hintStyle: const TextStyle(color: textSecondaryDark, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        dividerTheme: const DividerThemeData(
          color: dividerDark,
          thickness: 1,
          space: 1,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? primary : Colors.grey),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? primary.withOpacity(0.3)
                  : borderDark),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          thumbColor: primary,
          inactiveTrackColor: borderDark,
          trackHeight: 4,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: cardDarkElevated,
          contentTextStyle: const TextStyle(
            color: textPrimaryDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

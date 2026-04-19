import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF00A87E);
  static const Color accent = Color(0xFFF5B942);
  static const Color danger = Color(0xFFFF6B6B);

  // Light palette
  static const Color bgLight = Color(0xFFF4F6F3);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A2332);
  static const Color textSecondaryLight = Color(0xFF7A8599);
  static const Color borderLight = Color(0xFFE8ECE6);

  // Dark palette
  static const Color bgDark = Color(0xFF0F1117);
  static const Color surfaceDark = Color(0xFF171B24);
  static const Color cardDark = Color(0xFF1E2235);
  static const Color textPrimaryDark = Color(0xFFEDF0FF);
  static const Color textSecondaryDark = Color(0xFF7B85A0);
  static const Color borderDark = Color(0xFF262D40);

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
          backgroundColor: bgLight,
          foregroundColor: textPrimaryLight,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: textPrimaryLight),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F3EE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderLight, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: textSecondaryLight, fontSize: 14),
          hintStyle: const TextStyle(color: textSecondaryLight, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: borderLight,
          thickness: 1,
          space: 1,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? primary : Colors.white),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? primary.withOpacity(0.3)
                  : Colors.grey.shade300),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          thumbColor: primary,
          inactiveTrackColor: Color(0xFFDDE8D8),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: textPrimaryLight,
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
          backgroundColor: bgDark,
          foregroundColor: textPrimaryDark,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: textPrimaryDark),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderDark, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: textSecondaryDark, fontSize: 14),
          hintStyle: const TextStyle(color: textSecondaryDark, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: borderDark,
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
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: cardDark,
        ),
      );
}

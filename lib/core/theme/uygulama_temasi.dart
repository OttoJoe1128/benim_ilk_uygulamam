import 'package:flutter/material.dart';

ThemeData olusturTema() {
  final ColorScheme renk = ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4));
  return ThemeData(
    colorScheme: renk,
    useMaterial3: true,
    scaffoldBackgroundColor: renk.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: renk.surface,
      foregroundColor: renk.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: renk.primary)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: renk.primary,
        foregroundColor: renk.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: const StadiumBorder(),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
  );
}

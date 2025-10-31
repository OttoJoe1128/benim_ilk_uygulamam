import 'package:flutter/material.dart';

class UygulamaTema {
  const UygulamaTema._();

  static const Color _anaYesil = Color(0xFF2F9E44);
  static const Color _yardimciKrem = Color(0xFFF1F3E8);

  static ThemeData hazirlaAydinlikTema() {
    final ColorScheme renkPaleti = ColorScheme.fromSeed(seedColor: _anaYesil, brightness: Brightness.light);
    return ThemeData(
      colorScheme: renkPaleti,
      scaffoldBackgroundColor: _yardimciKrem,
      useMaterial3: true,
      textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Roboto'),
      appBarTheme: AppBarTheme(backgroundColor: renkPaleti.primary, foregroundColor: renkPaleti.onPrimary),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: renkPaleti.primary, foregroundColor: renkPaleti.onPrimary),
      ),
    );
  }

  static ThemeData hazirlaKoyuTema() {
    final ColorScheme renkPaleti = ColorScheme.fromSeed(seedColor: _anaYesil, brightness: Brightness.dark);
    return ThemeData(
      colorScheme: renkPaleti,
      scaffoldBackgroundColor: Colors.black,
      useMaterial3: true,
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      appBarTheme: AppBarTheme(backgroundColor: renkPaleti.surfaceVariant, foregroundColor: renkPaleti.onSurface),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: renkPaleti.primary, foregroundColor: renkPaleti.onPrimary),
      ),
    );
  }
}

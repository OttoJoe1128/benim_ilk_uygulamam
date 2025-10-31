import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class UygulamaDilleri {
  const UygulamaDilleri._();

  static const Locale varsayilanYerel = Locale('tr');

  static List<Locale> desteklenenYerelleriGetir() => const <Locale>[Locale('tr'), Locale('en')];

  static List<LocalizationsDelegate<dynamic>> yerellestirmeDelegeleriniGetir() => const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];
}

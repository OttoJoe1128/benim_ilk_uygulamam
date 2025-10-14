import 'package:flutter/foundation.dart';

@immutable
class IcerikFiltresi {
  const IcerikFiltresi._();

  static const List<String> yasakliKokler = <String>[
    'küfür1',
    'küfür2',
    'hakaret1',
  ];

  static bool hasUygunsuz(String metin) {
    final String k = metin.toLowerCase();
    return yasakliKokler.any((String w) => k.contains(w));
  }

  static String temizle(String metin) {
    String s = metin;
    for (final String w in yasakliKokler) {
      s = s.replaceAll(w, '***');
    }
    return s;
  }
}

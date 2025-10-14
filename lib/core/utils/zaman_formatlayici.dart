import 'package:flutter/foundation.dart';

@immutable
class ZamanFormatlayici {
  const ZamanFormatlayici._();

  static String formatKalanSure(DateTime hedef) {
    final Duration fark = hedef.difference(DateTime.now());
    if (fark.isNegative) return 'süre doldu';
    final int gun = fark.inDays;
    final int saat = fark.inHours % 24;
    final int dakika = fark.inMinutes % 60;
    if (gun > 0) return '${gun}g ${saat}s';
    if (saat > 0) return '${saat}s ${dakika}d';
    return '${fark.inMinutes}d';
  }
}

// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

enum SureSecenegi { birSaat, birGun, birHafta }

@immutable
class ZamanSabitleri {
  static const int saatSayisiBirGun = 24;
  static const int gunSayisiBirHafta = 7;
  static const Duration sureBirSaat = Duration(hours: 1);
  static const Duration sureBirGun = Duration(hours: saatSayisiBirGun);
  static const Duration sureBirHafta = Duration(days: gunSayisiBirHafta);
  const ZamanSabitleri._();
}

Duration donusturSureSecenegi(SureSecenegi secenek) {
  if (secenek == SureSecenegi.birSaat) {
    return ZamanSabitleri.sureBirSaat;
  }
  if (secenek == SureSecenegi.birGun) {
    return ZamanSabitleri.sureBirGun;
  }
  return ZamanSabitleri.sureBirHafta;
}

import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'package:benim_ilk_uygulamam/features/harita/depocular/parsel_konum_deposu.dart';
import 'package:benim_ilk_uygulamam/features/harita/varliklar/parsel.dart';

/// Geliştirme aşamasında dış servise gitmeden sahte bir parsel alanı döndürür.
/// Gerçek kullanımda MEGSIS/Parsel Sorgu veya QGIS/GeoJSON entegrasyonu yapılmalıdır.
class MockParselKonumDeposu implements ParselKonumDeposu {
  const MockParselKonumDeposu();

  @override
  Future<Parsel?> getirParselKonumu({
    required String arsaNo,
    required String adaNo,
    required String parselNo,
  }) async {
    // Girdi kombinasyonundan deterministik ama sahte bir koordinat üretelim.
    final int seed = _olusturTohum(
      arsaNo: arsaNo,
      adaNo: adaNo,
      parselNo: parselNo,
    );
    final math.Random rastgele = math.Random(seed);

    // Türkiye sınırları içinde makul bir konum (yaklaşık):
    final double enlem = 36.0 + rastgele.nextDouble() * 6.0; // 36 - 42
    final double boylam = 26.0 + rastgele.nextDouble() * 10.0; // 26 - 36

    // Küçük bir dörtgen poligon üretelim (~150-250m kenar)
    final double ofsetEnlem = 0.0015 + rastgele.nextDouble() * 0.001;
    final double ofsetBoylam = 0.0015 + rastgele.nextDouble() * 0.0015;

    final List<LatLng> poligon = <LatLng>[
      LatLng(enlem - ofsetEnlem, boylam - ofsetBoylam),
      LatLng(enlem - ofsetEnlem, boylam + ofsetBoylam),
      LatLng(enlem + ofsetEnlem, boylam + ofsetBoylam),
      LatLng(enlem + ofsetEnlem, boylam - ofsetBoylam),
    ];

    return Parsel(
      arsaNo: arsaNo,
      adaNo: adaNo,
      parselNo: parselNo,
      sinirNoktalari: poligon,
    );
  }

  int _olusturTohum({
    required String arsaNo,
    required String adaNo,
    required String parselNo,
  }) {
    final String birlesik = '$arsaNo-$adaNo-$parselNo';
    int toplam = 0;
    for (int i = 0; i < birlesik.length; i++) {
      toplam += birlesik.codeUnitAt(i) * (i + 1);
    }
    return toplam;
  }
}

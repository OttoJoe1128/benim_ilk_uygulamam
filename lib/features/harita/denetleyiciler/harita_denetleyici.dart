import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/harita_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/depocular/parsel_konum_deposu.dart';
import 'package:benim_ilk_uygulamam/features/harita/varliklar/parsel.dart';

class HaritaDenetleyici extends StateNotifier<HaritaDurumu> {
  final ParselKonumDeposu parselKonumDeposu;

  HaritaDenetleyici({required this.parselKonumDeposu}) : super(const IlkDurum());

  Future<void> araVeSec({
    required String arsaNo,
    required String adaNo,
    required String parselNo,
  }) async {
    if (arsaNo.isEmpty || adaNo.isEmpty || parselNo.isEmpty) {
      state = const HataDurumu(mesaj: 'Arsa/Ada/Parsel bilgileri boş olamaz');
      return;
    }
    state = const YukleniyorDurumu();
    try {
      final Parsel? parsel = await parselKonumDeposu.getirParselKonumu(
        arsaNo: arsaNo,
        adaNo: adaNo,
        parselNo: parselNo,
      );
      if (parsel == null) {
        state = const HataDurumu(mesaj: 'Parsel bulunamadı');
        return;
      }
      state = BasariliDurumu(seciliParsel: parsel);
    } catch (e) {
      state = HataDurumu(mesaj: 'Hata: ${e.toString()}');
    }
  }

  bool isNoktaPoligonIcinde({required LatLng nokta, required List<LatLng> poligon}) {
    // Ray casting algoritması
    bool icinde = false;
    for (int i = 0, j = poligon.length - 1; i < poligon.length; j = i++) {
      final double xi = poligon[i].longitude;
      final double yi = poligon[i].latitude;
      final double xj = poligon[j].longitude;
      final double yj = poligon[j].latitude;
      final bool kesisir = ((yi > nokta.latitude) != (yj > nokta.latitude)) &&
          (nokta.longitude < (xj - xi) * (nokta.latitude - yi) / (yj - yi + 0.0) + xi);
      if (kesisir) {
        icinde = !icinde;
      }
    }
    return icinde;
  }
}

final StateNotifierProvider<HaritaDenetleyici, HaritaDurumu> haritaDenetleyiciProvider =
    StateNotifierProvider<HaritaDenetleyici, HaritaDurumu>((Ref ref) {
  // Varsayılan olarak mock depo kullanılır; DI katmanına taşınabilir.
  // ignore: avoid_redundant_argument_values
  return HaritaDenetleyici(parselKonumDeposu: const _VarsayilanDepo());
});

/// Basit bir köprü: provider içinde mock bağımlılık
class _VarsayilanDepo implements ParselKonumDeposu {
  const _VarsayilanDepo();
  @override
  Future<Parsel?> getirParselKonumu({
    required String arsaNo,
    required String adaNo,
    required String parselNo,
  }) async {
    // Bu sınıf doğrudan mock sınıfını kullanmak yerine, derleme zamanı
    // bağımlılığını azaltmak için küçük bir re-implementasyon içerir.
    // Geliştirmede get_it/DI ile gerçek sınıf bağlanmalıdır.
    final String birlesik = '$arsaNo-$adaNo-$parselNo';
    int toplam = 0;
    for (int i = 0; i < birlesik.length; i++) {
      toplam += birlesik.codeUnitAt(i) * (i + 1);
    }
    final double enlem = 36.0 + (toplam % 1000) / 1000.0 * 6.0;
    final double boylam = 26.0 + (toplam % 1000) / 1000.0 * 10.0;
    const double ofsetE = 0.0018;
    const double ofsetB = 0.0022;
    final List<LatLng> poligon = <LatLng>[
      LatLng(enlem - ofsetE, boylam - ofsetB),
      LatLng(enlem - ofsetE, boylam + ofsetB),
      LatLng(enlem + ofsetE, boylam + ofsetB),
      LatLng(enlem + ofsetE, boylam - ofsetB),
    ];
    return Parsel(
      arsaNo: arsaNo,
      adaNo: adaNo,
      parselNo: parselNo,
      sinirNoktalari: poligon,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/features/harita/denetleyiciler/harita_durumu.dart';
import 'package:nova_agro/features/harita/depocular/parsel_konum_deposu.dart';
import 'package:nova_agro/features/harita/varliklar/parsel.dart';

class HaritaDenetleyici extends StateNotifier<HaritaDurumu> {
  final ParselKonumDeposu parselKonumDeposu;

  HaritaDenetleyici({required this.parselKonumDeposu})
    : super(const IlkDurum());

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

  bool isNoktaPoligonIcinde({
    required LatLng nokta,
    required List<LatLng> poligon,
  }) {
    // Ray casting algoritması
    bool icinde = false;
    for (int i = 0, j = poligon.length - 1; i < poligon.length; j = i++) {
      final double xi = poligon[i].longitude;
      final double yi = poligon[i].latitude;
      final double xj = poligon[j].longitude;
      final double yj = poligon[j].latitude;
      final bool kesisir =
          ((yi > nokta.latitude) != (yj > nokta.latitude)) &&
          (nokta.longitude <
              (xj - xi) * (nokta.latitude - yi) / (yj - yi + 0.0) + xi);
      if (kesisir) {
        icinde = !icinde;
      }
    }
    return icinde;
  }
}

final StateNotifierProvider<HaritaDenetleyici, HaritaDurumu>
haritaDenetleyiciProvider =
    StateNotifierProvider<HaritaDenetleyici, HaritaDurumu>((Ref ref) {
      final ParselKonumDeposu depo = hizmetBulucu<ParselKonumDeposu>();
      return HaritaDenetleyici(parselKonumDeposu: depo);
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/features/harita/denetleyiciler/hava_tahmini_durumu.dart';
import 'package:nova_agro/features/harita/servisler/hava_tahmini_servisi.dart';
import 'package:nova_agro/features/harita/varliklar/hava_durumu.dart';

class HavaTahminiDenetleyici extends StateNotifier<HavaTahminiDurumu> {
  final HavaTahminiServisi servis;

  HavaTahminiDenetleyici({required this.servis})
    : super(const HavaTahminiIlkDurum());

  Future<void> yukle({required LatLng konum}) async {
    state = const HavaTahminiYukleniyorDurumu();
    try {
      final HavaDurumu hava = await servis.getirHavaDurumu(konum: konum);
      state = HavaTahminiBasariliDurumu(havaDurumu: hava);
    } catch (e) {
      state = HavaTahminiHataDurumu(
        mesaj: 'Hava tahmini alınamadı: ${e.toString()}',
      );
    }
  }
}

final StateNotifierProvider<HavaTahminiDenetleyici, HavaTahminiDurumu>
havaTahminiDenetleyiciProvider =
    StateNotifierProvider<HavaTahminiDenetleyici, HavaTahminiDurumu>((Ref ref) {
      final HavaTahminiServisi servis = hizmetBulucu<HavaTahminiServisi>();
      return HavaTahminiDenetleyici(servis: servis);
    });

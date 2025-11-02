import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/features/harita/denetleyiciler/konum_durumu.dart';
import 'package:nova_agro/features/harita/hizmetler/konum_hizmeti.dart';

class KonumDenetleyici extends StateNotifier<KonumDurumu> {
  final KonumHizmeti konumHizmeti;

  KonumDenetleyici({required this.konumHizmeti})
    : super(const KonumBaslangicDurumu());

  Future<void> isteKonumVeIzinleri() async {
    final bool servisAcil = await konumHizmeti.isKonumServisiAcil();
    if (!servisAcil) {
      state = const KonumHataDurumu(
        mesaj: 'Konum servisi kapalı. Lütfen açın.',
      );
      await konumHizmeti.acKonumAyarlarini();
      return;
    }
    state = const KonumIzinBekleniyorDurumu();
    LocationPermission izinDurumu = await konumHizmeti.getirKonumIzinDurumu();
    if (izinDurumu == LocationPermission.denied) {
      izinDurumu = await konumHizmeti.isteKonumIzni();
    }
    if (izinDurumu == LocationPermission.deniedForever) {
      state = const KonumIzinRedDurumu(
        mesaj: 'Konum erişimi kalıcı olarak reddedildi. Ayarlardan izin verin.',
      );
      return;
    }
    if (izinDurumu != LocationPermission.always &&
        izinDurumu != LocationPermission.whileInUse) {
      state = const KonumIzinRedDurumu(mesaj: 'Konum izni gerekli.');
      return;
    }
    final PermissionStatus arkaPlanDurum = await konumHizmeti
        .isteArkaPlanIzni();
    if (arkaPlanDurum.isDenied) {
      state = const KonumIzinRedDurumu(
        mesaj: 'Arka plan konum izni reddedildi. Ayarlardan izin verin.',
      );
      return;
    }
    await _yukleKonum();
  }

  Future<void> yenileKonum() async {
    await _yukleKonum();
  }

  Future<void> _yukleKonum() async {
    state = const KonumYukleniyorDurumu();
    try {
      final LatLng konum = await konumHizmeti.getirGuncelKonum();
      state = KonumBasariliDurumu(kullaniciKonumu: konum);
    } catch (e) {
      state = KonumHataDurumu(mesaj: 'Konum alınırken hata: ${e.toString()}');
    }
  }
}

final StateNotifierProvider<KonumDenetleyici, KonumDurumu>
konumDenetleyiciProvider = StateNotifierProvider<KonumDenetleyici, KonumDurumu>(
  (Ref ref) {
    final KonumDenetleyici denetleyici = hizmetBulucu<KonumDenetleyici>();
    return denetleyici;
  },
);

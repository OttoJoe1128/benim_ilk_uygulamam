import 'package:nova_agro/features/harita/depocular/parsel_konum_deposu.dart';
import 'package:nova_agro/features/harita/varliklar/parsel.dart';
import 'package:nova_agro/features/harita/veri_kaynaklari/geojson_parsel_kaynagi.dart';

class GeojsonParselKonumDeposu implements ParselKonumDeposu {
  final GeojsonParselKaynagi kaynagi;
  const GeojsonParselKonumDeposu({required this.kaynagi});

  @override
  Future<Parsel?> getirParselKonumu({
    required String arsaNo,
    required String adaNo,
    required String parselNo,
  }) async {
    final GeojsonParselKayit? kayit = await kaynagi.bul(
      arsaNo: arsaNo,
      adaNo: adaNo,
      parselNo: parselNo,
    );
    if (kayit == null) return null;
    return Parsel(
      arsaNo: kayit.arsaNo,
      adaNo: kayit.adaNo,
      parselNo: kayit.parselNo,
      sinirNoktalari: kayit.sinirNoktalari,
    );
  }
}

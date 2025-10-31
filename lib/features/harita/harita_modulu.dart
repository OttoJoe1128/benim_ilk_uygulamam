import 'package:benim_ilk_uygulamam/core/di/hizmet_bulucu.dart';
import 'package:benim_ilk_uygulamam/features/harita/depocular/geojson_parsel_konum_deposu.dart';
import 'package:benim_ilk_uygulamam/features/harita/depocular/parsel_konum_deposu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/konum_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/hizmetler/konum_hizmeti.dart';
import 'package:benim_ilk_uygulamam/features/harita/veri_kaynaklari/geojson_parsel_kaynagi.dart';

void kurHaritaModulu() {
  if (hizmetBulucu.isRegistered<ParselKonumDeposu>()) {
    return;
  }
  hizmetBulucu.registerLazySingleton<GeojsonParselKaynagi>(
    () => GeojsonParselKaynagi(assetYolu: 'assets/geo/parseller.geojson'),
  );
  hizmetBulucu.registerLazySingleton<ParselKonumDeposu>(
    () =>
        GeojsonParselKonumDeposu(kaynagi: hizmetBulucu<GeojsonParselKaynagi>()),
  );
  hizmetBulucu.registerLazySingleton<KonumHizmeti>(KonumHizmeti.new);
  hizmetBulucu.registerFactory<KonumDenetleyici>(
    () => KonumDenetleyici(konumHizmeti: hizmetBulucu<KonumHizmeti>()),
  );
}

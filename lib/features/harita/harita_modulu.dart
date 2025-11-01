import 'package:dio/dio.dart';
import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/core/veritabani/veritabani_yonetici.dart';
import 'package:nova_agro/features/harita/depocular/geojson_parsel_konum_deposu.dart';
import 'package:nova_agro/features/harita/depocular/parsel_konum_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sensor_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sensor_sqlite_deposu.dart';
import 'package:nova_agro/features/harita/depocular/senkron_islem_deposu.dart';
import 'package:nova_agro/features/harita/depocular/senkron_islem_sqlite_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sulama_cizim_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sulama_cizim_sqlite_deposu.dart';
import 'package:nova_agro/features/harita/denetleyiciler/konum_denetleyici.dart';
import 'package:nova_agro/features/harita/hizmetler/konum_hizmeti.dart';
import 'package:nova_agro/features/harita/servisler/nova_cloud_servisi.dart';
import 'package:nova_agro/features/harita/senkronizasyon/senkron_yoneticisi.dart';
import 'package:nova_agro/features/harita/veri_kaynaklari/geojson_parsel_kaynagi.dart';

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
  hizmetBulucu.registerLazySingleton<VeritabaniYoneticisi>(
    VeritabaniYoneticisi.new,
  );
  hizmetBulucu.registerLazySingleton<Dio>(Dio.new);
  hizmetBulucu.registerLazySingleton<SensorDeposu>(
    () => SensorSqliteDeposu(
      veritabaniYoneticisi: hizmetBulucu<VeritabaniYoneticisi>(),
    ),
  );
  hizmetBulucu.registerLazySingleton<SulamaCizimDeposu>(
    () => SulamaCizimSqliteDeposu(
      veritabaniYoneticisi: hizmetBulucu<VeritabaniYoneticisi>(),
    ),
  );
  hizmetBulucu.registerLazySingleton<SenkronIslemDeposu>(
    () => SenkronIslemSqliteDeposu(
      veritabaniYoneticisi: hizmetBulucu<VeritabaniYoneticisi>(),
    ),
  );
  hizmetBulucu.registerLazySingleton<NovaCloudServisi>(
    () => NovaCloudServisiFake(dio: hizmetBulucu<Dio>()),
  );
  hizmetBulucu.registerLazySingleton<SenkronYoneticisi>(
    () => SenkronYoneticisi(
      novaCloudServisi: hizmetBulucu<NovaCloudServisi>(),
      senkronIslemDeposu: hizmetBulucu<SenkronIslemDeposu>(),
    ),
  );
}

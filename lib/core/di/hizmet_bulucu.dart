import 'package:get_it/get_it.dart';

import 'package:benim_ilk_uygulamam/core/veritabani/veritabani_yardimcisi.dart';
import 'package:benim_ilk_uygulamam/features/ai/depocular/sensor_sqlite_deposu.dart';
import 'package:benim_ilk_uygulamam/features/ai/nova_ai_servisi.dart';
import 'package:benim_ilk_uygulamam/features/ai/nova_ai_yoneticisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_baglantisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_kuyruk_yoneticisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_senkron_servisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/veri_kaynaklari/open_meteo_servisi.dart';
import 'package:http/http.dart' as http;

/// GetIt tabanl? servis bulucu.
final GetIt kurHizmetBulucu = GetIt.instance;

/// Uygulama servis kay?tlar?n? yapan ba?lang?? metodu.
Future<void> hazirlaHizmetBulucu() async {
  if (!kurHizmetBulucu.isRegistered<VeritabaniYardimcisi>()) {
    kurHizmetBulucu.registerLazySingleton<VeritabaniYardimcisi>(() => VeritabaniYardimcisi());
  }
  if (!kurHizmetBulucu.isRegistered<MqttBaglantisi>()) {
    kurHizmetBulucu.registerLazySingleton<MqttBaglantisi>(() => const MqttBaglantisi());
  }
  if (!kurHizmetBulucu.isRegistered<MqttBaglantiDurumDenetleyici>()) {
    kurHizmetBulucu.registerLazySingleton<MqttBaglantiDurumDenetleyici>(() => MqttBaglantiDurumDenetleyici());
  }
  if (!kurHizmetBulucu.isRegistered<MqttKuyrukYoneticisi>()) {
    kurHizmetBulucu.registerLazySingleton<MqttKuyrukYoneticisi>(() => MqttKuyrukYoneticisi(veritabaniYardimcisi: kurHizmetBulucu<VeritabaniYardimcisi>()));
  }
  if (!kurHizmetBulucu.isRegistered<MqttSenkronServisi>()) {
    kurHizmetBulucu.registerLazySingleton<MqttSenkronServisi>(() => MqttSenkronServisi(baglanti: kurHizmetBulucu<MqttBaglantisi>(), kuyrukYoneticisi: kurHizmetBulucu<MqttKuyrukYoneticisi>(), durumDenetleyici: kurHizmetBulucu<MqttBaglantiDurumDenetleyici>()));
  }
  if (!kurHizmetBulucu.isRegistered<http.Client>()) {
    kurHizmetBulucu.registerLazySingleton<http.Client>(() => http.Client());
  }
  if (!kurHizmetBulucu.isRegistered<SensorSqliteDeposu>()) {
    kurHizmetBulucu.registerLazySingleton<SensorSqliteDeposu>(() => SensorSqliteDeposu(veritabaniYardimcisi: kurHizmetBulucu<VeritabaniYardimcisi>()));
  }
  if (!kurHizmetBulucu.isRegistered<NovaAiYoneticisi>()) {
    kurHizmetBulucu.registerLazySingleton<NovaAiYoneticisi>(() => NovaAiYoneticisi());
  }
  if (!kurHizmetBulucu.isRegistered<NovaAiServisi>()) {
    kurHizmetBulucu.registerLazySingleton<NovaAiServisi>(() => NovaAiServisi(sensorDeposu: kurHizmetBulucu<SensorSqliteDeposu>(), yonetici: kurHizmetBulucu<NovaAiYoneticisi>()));
  }
  if (!kurHizmetBulucu.isRegistered<OpenMeteoServisi>()) {
    kurHizmetBulucu.registerLazySingleton<OpenMeteoServisi>(() => OpenMeteoServisi(httpIstemcisi: kurHizmetBulucu<http.Client>(), mqttSenkronServisi: kurHizmetBulucu<MqttSenkronServisi>(), novaAiServisi: kurHizmetBulucu<NovaAiServisi>()));
  }
}

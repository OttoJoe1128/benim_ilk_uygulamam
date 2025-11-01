import 'dart:async';
import 'dart:convert';

import 'package:latlong2/latlong.dart';

import 'package:nova_agro/features/harita/depocular/senkron_islem_deposu.dart';
import 'package:nova_agro/features/harita/servisler/nova_cloud_servisi.dart';
import 'package:nova_agro/features/harita/varliklar/sensor.dart';
import 'package:nova_agro/features/harita/varliklar/senkron_islem.dart';

class SenkronYoneticisi {
  final NovaCloudServisi novaCloudServisi;
  final SenkronIslemDeposu senkronIslemDeposu;
  bool _senkronizasyonSuruyor = false;

  SenkronYoneticisi({
    required this.novaCloudServisi,
    required this.senkronIslemDeposu,
  });

  Future<void> senkronizeBekleyenIslemler() async {
    if (_senkronizasyonSuruyor) {
      return;
    }
    _senkronizasyonSuruyor = true;
    try {
      final List<SenkronIslem> islemler = await senkronIslemDeposu
          .getirBekleyenIslemler();
      for (final SenkronIslem islem in islemler) {
        final bool basarili = await _islemiCalistir(islem: islem);
        if (!basarili) {
          break;
        }
        await senkronIslemDeposu.silIslem(islemId: islem.id!);
      }
    } finally {
      _senkronizasyonSuruyor = false;
    }
  }

  Future<void> senkronizeSensorEkle({required Sensor sensor}) async {
    final bool basarili = await _calistirVeKaydet(
      islemTuru: SenkronIslemTuru.sensorEkle,
      veri: <String, Object?>{'sensor': _sensorToMap(sensor)},
      calistir: () => novaCloudServisi.gonderSensor(sensor: sensor),
    );
    if (!basarili) {
      await senkronizeBekleyenIslemler();
    }
  }

  Future<void> senkronizeSensorGuncelle({required Sensor sensor}) async {
    final bool basarili = await _calistirVeKaydet(
      islemTuru: SenkronIslemTuru.sensorGuncelle,
      veri: <String, Object?>{'sensor': _sensorToMap(sensor)},
      calistir: () => novaCloudServisi.guncelleSensor(sensor: sensor),
    );
    if (!basarili) {
      await senkronizeBekleyenIslemler();
    }
  }

  Future<void> senkronizeSensorSil({required String sensorId}) async {
    final bool basarili = await _calistirVeKaydet(
      islemTuru: SenkronIslemTuru.sensorSil,
      veri: <String, Object?>{'sensorId': sensorId},
      calistir: () => novaCloudServisi.silSensor(sensorId: sensorId),
    );
    if (!basarili) {
      await senkronizeBekleyenIslemler();
    }
  }

  Future<void> senkronizeSulamaKaydet({required List<LatLng> noktalar}) async {
    final bool basarili = await _calistirVeKaydet(
      islemTuru: SenkronIslemTuru.sulamaKaydet,
      veri: <String, Object?>{
        'noktalar': noktalar
            .map(
              (LatLng nokta) => <String, Object?>{
                'lat': nokta.latitude,
                'lng': nokta.longitude,
              },
            )
            .toList(),
      },
      calistir: () =>
          novaCloudServisi.gonderSulamaNoktalari(noktalar: noktalar),
    );
    if (!basarili) {
      await senkronizeBekleyenIslemler();
    }
  }

  Future<bool> _calistirVeKaydet({
    required SenkronIslemTuru islemTuru,
    required Map<String, Object?> veri,
    required Future<void> Function() calistir,
  }) async {
    try {
      await calistir();
      return true;
    } catch (_) {
      await senkronIslemDeposu.ekleIslem(
        islem: SenkronIslem(
          tur: islemTuru,
          veri: SenkronIslem.veriToJson(veri),
          olusturmaZamani: DateTime.now(),
        ),
      );
      return false;
    }
  }

  Map<String, Object?> _sensorToMap(Sensor sensor) {
    return <String, Object?>{
      'id': sensor.id,
      'ad': sensor.ad,
      'lat': sensor.konum.latitude,
      'lng': sensor.konum.longitude,
      'olusturma_zamani': sensor.olusturmaZamani.toIso8601String(),
    };
  }

  Future<bool> _islemiCalistir({required SenkronIslem islem}) async {
    try {
      switch (islem.tur) {
        case SenkronIslemTuru.sensorEkle:
          final Map<String, Object?> veri =
              json.decode(islem.veri) as Map<String, Object?>;
          final Map<String, Object?> sensorMap =
              veri['sensor']! as Map<String, Object?>;
          await novaCloudServisi.gonderSensor(
            sensor: _sensorFromMap(sensorMap),
          );
          break;
        case SenkronIslemTuru.sensorGuncelle:
          final Map<String, Object?> veri =
              json.decode(islem.veri) as Map<String, Object?>;
          final Map<String, Object?> sensorMap =
              veri['sensor']! as Map<String, Object?>;
          await novaCloudServisi.guncelleSensor(
            sensor: _sensorFromMap(sensorMap),
          );
          break;
        case SenkronIslemTuru.sensorSil:
          final Map<String, Object?> veri =
              json.decode(islem.veri) as Map<String, Object?>;
          await novaCloudServisi.silSensor(
            sensorId: veri['sensorId']! as String,
          );
          break;
        case SenkronIslemTuru.sulamaKaydet:
          final Map<String, Object?> veri =
              json.decode(islem.veri) as Map<String, Object?>;
          final List<Object?> noktalar = veri['noktalar']! as List<Object?>;
          await novaCloudServisi.gonderSulamaNoktalari(
            noktalar: noktalar
                .map((Object? nokta) => nokta! as Map<String, Object?>)
                .map(
                  (Map<String, Object?> map) => LatLng(
                    (map['lat']! as num).toDouble(),
                    (map['lng']! as num).toDouble(),
                  ),
                )
                .toList(),
          );
          break;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Sensor _sensorFromMap(Map<String, Object?> map) {
    return Sensor(
      id: map['id']! as String,
      ad: map['ad']! as String,
      konum: LatLng(
        (map['lat']! as num).toDouble(),
        (map['lng']! as num).toDouble(),
      ),
      olusturmaZamani: DateTime.parse(map['olusturma_zamani']! as String),
    );
  }
}

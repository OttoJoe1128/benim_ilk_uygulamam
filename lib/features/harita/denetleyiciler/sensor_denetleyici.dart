import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/features/harita/denetleyiciler/sensor_durumu.dart';
import 'package:nova_agro/features/harita/depocular/sensor_deposu.dart';
import 'package:nova_agro/features/harita/senkronizasyon/senkron_yoneticisi.dart';
import 'package:nova_agro/features/harita/varliklar/sensor.dart';

class SensorDenetleyici extends StateNotifier<SensorDurumu> {
  final SensorDeposu sensorDeposu;
  final Uuid uuid;
  final SenkronYoneticisi senkronYoneticisi;

  SensorDenetleyici({
    required this.sensorDeposu,
    required this.uuid,
    required this.senkronYoneticisi,
  }) : super(SensorDurumu.ilk());

  Future<void> yukleSensorler() async {
    state = state.kopyala(isYukleniyor: true, hataMesajiniTemizle: true);
    try {
      final List<Sensor> sensorler = await sensorDeposu.getirSensorler();
      state = state.kopyala(
        sensorler: sensorler,
        isYukleniyor: false,
        hataMesajiniTemizle: true,
      );
      await senkronYoneticisi.senkronizeBekleyenIslemler();
    } catch (e) {
      state = state.kopyala(
        isYukleniyor: false,
        hataMesaji: 'Sensörler yüklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> ekleSensor({required String ad, required LatLng konum}) async {
    if (ad.trim().isEmpty) {
      state = state.kopyala(hataMesaji: 'Sensör adı boş olamaz');
      return;
    }
    final Sensor sensor = Sensor(
      id: uuid.v4(),
      ad: ad.trim(),
      konum: konum,
      olusturmaZamani: DateTime.now(),
    );
    try {
      await sensorDeposu.ekleSensor(sensor: sensor);
      final List<Sensor> guncel = List<Sensor>.from(state.sensorler)
        ..add(sensor);
      state = state.kopyala(sensorler: guncel, hataMesajiniTemizle: true);
      await senkronYoneticisi.senkronizeSensorEkle(sensor: sensor);
    } catch (e) {
      state = state.kopyala(hataMesaji: 'Sensör eklenemedi: ${e.toString()}');
    }
  }

  Future<void> guncelleSensor({
    required String sensorId,
    required String ad,
  }) async {
    if (ad.trim().isEmpty) {
      state = state.kopyala(hataMesaji: 'Sensör adı boş olamaz');
      return;
    }
    final Sensor mevcut = state.sensorler.firstWhere(
      (Sensor sensor) => sensor.id == sensorId,
      orElse: () => throw StateError('Sensör bulunamadı'),
    );
    final Sensor guncelSensor = mevcut.kopyala(ad: ad.trim());
    try {
      await sensorDeposu.guncelleSensor(sensor: guncelSensor);
      final List<Sensor> guncelListe = state.sensorler
          .map((Sensor sensor) => sensor.id == sensorId ? guncelSensor : sensor)
          .toList();
      state = state.kopyala(
        sensorler: guncelListe,
        hataMesajiniTemizle: true,
        duzenlenenSensoruTemizle: true,
      );
      await senkronYoneticisi.senkronizeSensorGuncelle(sensor: guncelSensor);
    } catch (e) {
      state = state.kopyala(
        hataMesaji: 'Sensör güncellenemedi: ${e.toString()}',
      );
    }
  }

  Future<void> silSensor({required String sensorId}) async {
    try {
      await sensorDeposu.silSensor(sensorId: sensorId);
      final List<Sensor> guncel = state.sensorler
          .where((Sensor sensor) => sensor.id != sensorId)
          .toList();
      state = state.kopyala(sensorler: guncel, hataMesajiniTemizle: true);
      await senkronYoneticisi.senkronizeSensorSil(sensorId: sensorId);
    } catch (e) {
      state = state.kopyala(hataMesaji: 'Sensör silinemedi: ${e.toString()}');
    }
  }

  void secDuzenlenecekSensor({Sensor? sensor}) {
    state = state.kopyala(duzenlenenSensor: sensor, hataMesajiniTemizle: true);
  }
}

final StateNotifierProvider<SensorDenetleyici, SensorDurumu>
sensorDenetleyiciProvider =
    StateNotifierProvider<SensorDenetleyici, SensorDurumu>((Ref ref) {
      final SensorDeposu depo = hizmetBulucu<SensorDeposu>();
      final SenkronYoneticisi senkronYoneticisi =
          hizmetBulucu<SenkronYoneticisi>();
      return SensorDenetleyici(
        sensorDeposu: depo,
        uuid: const Uuid(),
        senkronYoneticisi: senkronYoneticisi,
      );
    });

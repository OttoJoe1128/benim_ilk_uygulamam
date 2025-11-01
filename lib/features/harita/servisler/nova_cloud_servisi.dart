import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import 'package:nova_agro/features/harita/varliklar/sensor.dart';

abstract class NovaCloudServisi {
  Future<List<Sensor>> cekSensorler();
  Future<void> gonderSensor({required Sensor sensor});
  Future<void> guncelleSensor({required Sensor sensor});
  Future<void> silSensor({required String sensorId});
  Future<void> gonderSulamaNoktalari({required List<LatLng> noktalar});
}

class NovaCloudServisiFake implements NovaCloudServisi {
  final Dio dio;
  final Duration gecikme;
  final double hataOlasiligi;
  final Random _random;
  final Map<String, Sensor> _uzakSensorler = <String, Sensor>{};
  List<LatLng> _uzakSulamaNoktalari = <LatLng>[];

  NovaCloudServisiFake({
    Dio? dio,
    this.gecikme = const Duration(milliseconds: 250),
    this.hataOlasiligi = 0.1,
    Random? random,
  }) : dio = dio ?? Dio(),
       _random = random ?? Random();

  Future<void> _simuleGecikme() async {
    await Future<void>.delayed(gecikme);
    if (_random.nextDouble() < hataOlasiligi) {
      throw DioException(
        requestOptions: RequestOptions(path: '/nova-cloud'),
        message: 'Simüle senkronizasyon hatası',
      );
    }
  }

  @override
  Future<List<Sensor>> cekSensorler() async {
    await _simuleGecikme();
    return _uzakSensorler.values.toList()..sort(
      (Sensor a, Sensor b) => a.olusturmaZamani.compareTo(b.olusturmaZamani),
    );
  }

  @override
  Future<void> gonderSensor({required Sensor sensor}) async {
    await _simuleGecikme();
    _uzakSensorler[sensor.id] = sensor;
  }

  @override
  Future<void> guncelleSensor({required Sensor sensor}) async {
    await _simuleGecikme();
    _uzakSensorler[sensor.id] = sensor;
  }

  @override
  Future<void> silSensor({required String sensorId}) async {
    await _simuleGecikme();
    _uzakSensorler.remove(sensorId);
  }

  @override
  Future<void> gonderSulamaNoktalari({required List<LatLng> noktalar}) async {
    await _simuleGecikme();
    _uzakSulamaNoktalari = List<LatLng>.from(noktalar);
  }

  List<LatLng> get uzakSulamaNoktalari =>
      List<LatLng>.unmodifiable(_uzakSulamaNoktalari);
}

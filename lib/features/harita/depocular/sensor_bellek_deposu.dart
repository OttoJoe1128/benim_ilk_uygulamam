import 'package:benim_ilk_uygulamam/features/harita/depocular/sensor_deposu.dart';
import 'package:benim_ilk_uygulamam/features/harita/varliklar/sensor.dart';

class SensorBellekDeposu implements SensorDeposu {
  final List<Sensor> _sensorler = <Sensor>[];

  @override
  Future<List<Sensor>> getirSensorler() async {
    return List<Sensor>.unmodifiable(_sensorler);
  }

  @override
  Future<Sensor> ekleSensor({required Sensor sensor}) async {
    final bool ayniKayitVar = _sensorler.any(
      (Sensor mevcut) =>
          mevcut.id == sensor.id ||
          (mevcut.ad == sensor.ad && mevcut.konum == sensor.konum),
    );
    if (ayniKayitVar) {
      throw StateError('Aynı sensör tekrar eklenemez');
    }
    _sensorler.add(sensor);
    return sensor;
  }

  @override
  Future<Sensor> guncelleSensor({required Sensor sensor}) async {
    final int indeks = _sensorler.indexWhere(
      (Sensor mevcut) => mevcut.id == sensor.id,
    );
    if (indeks == -1) {
      throw StateError('Sensör bulunamadı');
    }
    _sensorler[indeks] = sensor;
    return sensor;
  }

  @override
  Future<void> silSensor({required String sensorId}) async {
    _sensorler.removeWhere((Sensor mevcut) => mevcut.id == sensorId);
  }
}

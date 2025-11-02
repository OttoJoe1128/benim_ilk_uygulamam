import 'package:nova_agro/features/harita/varliklar/sensor.dart';

abstract class SensorDeposu {
  Future<List<Sensor>> getirSensorler();
  Future<Sensor> ekleSensor({required Sensor sensor});
  Future<Sensor> guncelleSensor({required Sensor sensor});
  Future<void> silSensor({required String sensorId});
}

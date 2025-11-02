import 'package:nova_agro/features/harita/varliklar/sensor.dart';

class SensorDurumu {
  final List<Sensor> sensorler;
  final bool isYukleniyor;
  final String? hataMesaji;
  final Sensor? duzenlenenSensor;

  const SensorDurumu({
    required this.sensorler,
    required this.isYukleniyor,
    required this.hataMesaji,
    required this.duzenlenenSensor,
  });

  factory SensorDurumu.ilk() {
    return const SensorDurumu(
      sensorler: <Sensor>[],
      isYukleniyor: false,
      hataMesaji: null,
      duzenlenenSensor: null,
    );
  }

  SensorDurumu kopyala({
    List<Sensor>? sensorler,
    bool? isYukleniyor,
    String? hataMesaji,
    bool hataMesajiniTemizle = false,
    Sensor? duzenlenenSensor,
    bool duzenlenenSensoruTemizle = false,
  }) {
    return SensorDurumu(
      sensorler: sensorler ?? this.sensorler,
      isYukleniyor: isYukleniyor ?? this.isYukleniyor,
      hataMesaji: hataMesajiniTemizle ? null : (hataMesaji ?? this.hataMesaji),
      duzenlenenSensor: duzenlenenSensoruTemizle
          ? null
          : (duzenlenenSensor ?? this.duzenlenenSensor),
    );
  }
}

import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';

import 'package:benim_ilk_uygulamam/core/veritabani/veritabani_yonetici.dart';
import 'package:benim_ilk_uygulamam/features/harita/depocular/sensor_deposu.dart';
import 'package:benim_ilk_uygulamam/features/harita/varliklar/sensor.dart';

class SensorSqliteDeposu implements SensorDeposu {
  final VeritabaniYoneticisi veritabaniYoneticisi;

  const SensorSqliteDeposu({required this.veritabaniYoneticisi});

  String _cekIso8601(DateTime zaman) {
    return zaman.toIso8601String();
  }

  Future<Database> _cekVeritabani() async {
    return veritabaniYoneticisi.ac();
  }

  Sensor _haritadanOlustur(Map<String, Object?> kayit) {
    return Sensor(
      id: kayit['id']! as String,
      ad: kayit['ad']! as String,
      konum: LatLng(
        (kayit['lat']! as num).toDouble(),
        (kayit['lng']! as num).toDouble(),
      ),
      olusturmaZamani: DateTime.parse(kayit['olusturma_zamani']! as String),
    );
  }

  @override
  Future<List<Sensor>> getirSensorler() async {
    final Database db = await _cekVeritabani();
    final List<Map<String, Object?>> sonuc = await db.query(
      'sensorler',
      orderBy: 'olusturma_zamani ASC',
    );
    return sonuc.map(_haritadanOlustur).toList();
  }

  @override
  Future<Sensor> ekleSensor({required Sensor sensor}) async {
    final Database db = await _cekVeritabani();
    final bool ayniKayitVar = (await db.query(
      'sensorler',
      where: 'id = ? OR (ad = ? AND lat = ? AND lng = ?)',
      whereArgs: <Object?>[
        sensor.id,
        sensor.ad,
        sensor.konum.latitude,
        sensor.konum.longitude,
      ],
    )).isNotEmpty;
    if (ayniKayitVar) {
      throw StateError('Aynı sensör tekrar eklenemez');
    }
    await db.insert('sensorler', <String, Object?>{
      'id': sensor.id,
      'ad': sensor.ad,
      'lat': sensor.konum.latitude,
      'lng': sensor.konum.longitude,
      'olusturma_zamani': _cekIso8601(sensor.olusturmaZamani),
    }, conflictAlgorithm: ConflictAlgorithm.abort);
    return sensor;
  }

  @override
  Future<Sensor> guncelleSensor({required Sensor sensor}) async {
    final Database db = await _cekVeritabani();
    final int guncellenen = await db.update(
      'sensorler',
      <String, Object?>{
        'ad': sensor.ad,
        'lat': sensor.konum.latitude,
        'lng': sensor.konum.longitude,
      },
      where: 'id = ?',
      whereArgs: <Object?>[sensor.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    if (guncellenen == 0) {
      throw StateError('Sensör bulunamadı');
    }
    return sensor;
  }

  @override
  Future<void> silSensor({required String sensorId}) async {
    final Database db = await _cekVeritabani();
    await db.delete(
      'sensorler',
      where: 'id = ?',
      whereArgs: <Object?>[sensorId],
    );
  }
}

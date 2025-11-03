import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'package:benim_ilk_uygulamam/core/veritabani/veritabani_yardimcisi.dart';

/// MQTT i?lemlerini ?evrimd??? kuyru?a yaz?p y?neten s?n?f.
class MqttKuyrukYoneticisi {
  final VeritabaniYardimcisi veritabaniYardimcisi;
  static const String tabloAdi = 'senkron_kuyruk';
  const MqttKuyrukYoneticisi({required this.veritabaniYardimcisi});

  Future<void> ekleIslem({required String payload}) async {
    final Database db = await veritabaniYardimcisi.ac();
    final List<Map<String, Object?>> mevcutKayitlar = await db.query(tabloAdi, where: 'payload = ? AND gonderildi = 0', whereArgs: <Object>[payload]);
    if (mevcutKayitlar.isNotEmpty) {
      return;
    }
    final int simdi = DateTime.now().millisecondsSinceEpoch;
    await db.insert(tabloAdi, <String, Object>{'payload': payload, 'timestamp': simdi, 'gonderildi': 0});
  }

  Future<List<SenkronKaydi>> getirBekleyenler() async {
    final Database db = await veritabaniYardimcisi.ac();
    final List<Map<String, Object?>> satirlar = await db.query(tabloAdi, where: 'gonderildi = 0', orderBy: 'timestamp ASC');
    final List<SenkronKaydi> kayitlar = satirlar.map((Map<String, Object?> satir) {
      final SenkronKaydi kayit = SenkronKaydi(id: satir['id'] as int, payload: satir['payload'] as String, zamanDamgasi: satir['timestamp'] as int, gonderildi: (satir['gonderildi'] as int) == 1);
      return kayit;
    }).toList();
    return kayitlar;
  }

  Future<void> isaretleGonderildi({required int id}) async {
    final Database db = await veritabaniYardimcisi.ac();
    await db.update(tabloAdi, <String, Object>{'gonderildi': 1}, where: 'id = ?', whereArgs: <Object>[id]);
  }
}

/// Senkron kuyru?undaki bir i?leme ait veri transfer nesnesi.
class SenkronKaydi {
  final int id;
  final String payload;
  final int zamanDamgasi;
  final bool gonderildi;
  const SenkronKaydi({required this.id, required this.payload, required this.zamanDamgasi, required this.gonderildi});
}

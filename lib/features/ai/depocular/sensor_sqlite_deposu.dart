import 'package:sqflite/sqflite.dart';

import 'package:benim_ilk_uygulamam/core/veritabani/veritabani_yardimcisi.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/sensor_olcumu.dart';

/// Sens?r verilerini SQLite ?zerinde y?neten depo s?n?f?.
class SensorSqliteDeposu {
  final VeritabaniYardimcisi veritabaniYardimcisi;
  static const String tabloAdi = 'sensor_veri';
  const SensorSqliteDeposu({required this.veritabaniYardimcisi});

  Future<void> kaydetOlcum({required SensorOlcumu olcum}) async {
    final Database db = await veritabaniYardimcisi.ac();
    await _tabloyuHazirla(db: db);
    final List<Map<String, Object?>> mevcut = await db.query(tabloAdi, columns: <String>['id'], where: 'olcum_zamani = ?', whereArgs: <Object>[olcum.olcumZamani.millisecondsSinceEpoch], limit: 1);
    if (mevcut.isNotEmpty) {
      return;
    }
    await db.insert(tabloAdi, olcum.haritayaDonustur());
  }

  Future<List<SensorOlcumu>> getirSonOlcumler({int limit = 20}) async {
    final Database db = await veritabaniYardimcisi.ac();
    await _tabloyuHazirla(db: db);
    final List<Map<String, Object?>> satirlar = await db.query(tabloAdi, orderBy: 'olcum_zamani DESC', limit: limit);
    final List<SensorOlcumu> olcumler = satirlar.map((Map<String, Object?> satir) {
      final SensorOlcumu olcum = SensorOlcumu.haritadanDonustur(kayit: satir);
      return olcum;
    }).toList();
    return olcumler;
  }

  Future<SensorOlcumu?> getirSonOlcum() async {
    final List<SensorOlcumu> olcumler = await getirSonOlcumler(limit: 1);
    if (olcumler.isEmpty) {
      return null;
    }
    return olcumler.first;
  }

  Future<void> _tabloyuHazirla({required Database db}) async {
    await db.execute('CREATE TABLE IF NOT EXISTS $tabloAdi (id INTEGER PRIMARY KEY AUTOINCREMENT,toprak_nemi REAL NOT NULL,toprak_sicakligi REAL NOT NULL,hava_sicakligi REAL NOT NULL,isik_seviyesi REAL NOT NULL,bagil_nem REAL NOT NULL,olcum_zamani INTEGER NOT NULL UNIQUE,kaynak TEXT NOT NULL)');
  }
}

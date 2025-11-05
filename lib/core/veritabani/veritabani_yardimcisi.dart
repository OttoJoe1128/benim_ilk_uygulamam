import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as yol_islemleri;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Uygulama genelinde SQLite ba?lant?s?n? y?neten yard?mc? s?n?f.
class VeritabaniYardimcisi {
  static Database? _veritabani;
  static const String _veritabaniAdi = 'nova_agro.db';
  static const int _surum = 1;

  Future<Database> ac({String? testDizini}) async {
    if (_veritabani != null) {
      return _veritabani!;
    }
    final String yol = await _olusturYol(testDizini: testDizini);
    final Database veritabani = await openDatabase(yol, version: _surum, onCreate: (Database db, int surum) async {
      await _olusturTablolar(db: db);
    }, onUpgrade: (Database db, int eskiSurum, int yeniSurum) async {
      await _yukseltTablolar(db: db, eskiSurum: eskiSurum, yeniSurum: yeniSurum);
    });
    _veritabani = veritabani;
    return veritabani;
  }

  Future<String> _olusturYol({String? testDizini}) async {
    if (testDizini != null) {
      return yol_islemleri.join(testDizini, _veritabaniAdi);
    }
    final Directory uygulamaDizini = await getApplicationDocumentsDirectory();
    final String yol = yol_islemleri.join(uygulamaDizini.path, _veritabaniAdi);
    return yol;
  }

  Future<void> _olusturTablolar({required Database db}) async {
    await db.execute('CREATE TABLE IF NOT EXISTS senkron_kuyruk (id INTEGER PRIMARY KEY AUTOINCREMENT,payload TEXT NOT NULL,timestamp INTEGER NOT NULL,gonderildi INTEGER NOT NULL DEFAULT 0)');
    await db.execute('CREATE TABLE IF NOT EXISTS sensor_veri (id INTEGER PRIMARY KEY AUTOINCREMENT,toprak_nemi REAL NOT NULL,toprak_sicakligi REAL NOT NULL,hava_sicakligi REAL NOT NULL,isik_seviyesi REAL NOT NULL,bagil_nem REAL NOT NULL,olcum_zamani INTEGER NOT NULL UNIQUE,kaynak TEXT NOT NULL)');
  }

  Future<void> _yukseltTablolar({required Database db, required int eskiSurum, required int yeniSurum}) async {
    if (eskiSurum < 1 && yeniSurum >= 1) {
      await db.execute('CREATE TABLE IF NOT EXISTS senkron_kuyruk (id INTEGER PRIMARY KEY AUTOINCREMENT,payload TEXT NOT NULL,timestamp INTEGER NOT NULL,gonderildi INTEGER NOT NULL DEFAULT 0)');
      await db.execute('CREATE TABLE IF NOT EXISTS sensor_veri (id INTEGER PRIMARY KEY AUTOINCREMENT,toprak_nemi REAL NOT NULL,toprak_sicakligi REAL NOT NULL,hava_sicakligi REAL NOT NULL,isik_seviyesi REAL NOT NULL,bagil_nem REAL NOT NULL,olcum_zamani INTEGER NOT NULL UNIQUE,kaynak TEXT NOT NULL)');
    }
  }
}

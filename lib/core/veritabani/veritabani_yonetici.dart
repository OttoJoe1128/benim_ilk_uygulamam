import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class VeritabaniYoneticisi {
  Database? _veritabani;

  Future<Database> ac() async {
    if (_veritabani != null) {
      return _veritabani!;
    }
    final String dizin = await getDatabasesPath();
    final String yol = p.join(dizin, 'nova_agro.db');
    _veritabani = await openDatabase(
      yol,
      version: 1,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE sensorler (id TEXT PRIMARY KEY, ad TEXT NOT NULL, lat REAL NOT NULL, lng REAL NOT NULL, olusturma_zamani TEXT NOT NULL, UNIQUE(ad, lat, lng))',
        );
        await db.execute(
          'CREATE TABLE sulama_noktalari (sirano INTEGER PRIMARY KEY AUTOINCREMENT, sira INTEGER NOT NULL, lat REAL NOT NULL, lng REAL NOT NULL)',
        );
      },
    );
    return _veritabani!;
  }
}

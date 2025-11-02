import 'package:sqflite/sqflite.dart';

import 'package:nova_agro/core/veritabani/veritabani_yonetici.dart';
import 'package:nova_agro/features/harita/depocular/senkron_islem_deposu.dart';
import 'package:nova_agro/features/harita/varliklar/senkron_islem.dart';

class SenkronIslemSqliteDeposu implements SenkronIslemDeposu {
  final VeritabaniYoneticisi veritabaniYoneticisi;

  const SenkronIslemSqliteDeposu({required this.veritabaniYoneticisi});

  Future<Database> _cekVeritabani() async {
    return veritabaniYoneticisi.ac();
  }

  @override
  Future<SenkronIslem> ekleIslem({required SenkronIslem islem}) async {
    final Database db = await _cekVeritabani();
    final int id = await db.insert('senkron_islemler', islem.toMap());
    return islem.kopyala(id: id);
  }

  @override
  Future<List<SenkronIslem>> getirBekleyenIslemler() async {
    final Database db = await _cekVeritabani();
    final List<Map<String, Object?>> kayitlar = await db.query(
      'senkron_islemler',
      orderBy: 'olusturma_zamani ASC, id ASC',
    );
    return kayitlar.map(SenkronIslem.fromMap).toList();
  }

  @override
  Future<void> silIslem({required int islemId}) async {
    final Database db = await _cekVeritabani();
    await db.delete(
      'senkron_islemler',
      where: 'id = ?',
      whereArgs: <Object?>[islemId],
    );
  }
}

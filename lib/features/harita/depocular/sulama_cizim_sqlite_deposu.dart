import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';

import 'package:benim_ilk_uygulamam/core/veritabani/veritabani_yonetici.dart';
import 'package:benim_ilk_uygulamam/features/harita/depocular/sulama_cizim_deposu.dart';

class SulamaCizimSqliteDeposu implements SulamaCizimDeposu {
  final VeritabaniYoneticisi veritabaniYoneticisi;

  const SulamaCizimSqliteDeposu({required this.veritabaniYoneticisi});

  Future<Database> _cekVeritabani() async {
    return veritabaniYoneticisi.ac();
  }

  @override
  Future<List<LatLng>> getirNoktalar() async {
    final Database db = await _cekVeritabani();
    final List<Map<String, Object?>> kayitlar = await db.query(
      'sulama_noktalari',
      orderBy: 'sira ASC',
    );
    return kayitlar
        .map(
          (Map<String, Object?> kayit) => LatLng(
            (kayit['lat']! as num).toDouble(),
            (kayit['lng']! as num).toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<void> kaydetNoktalar({required List<LatLng> noktalar}) async {
    final Database db = await _cekVeritabani();
    final Batch batch = db.batch();
    batch.delete('sulama_noktalari');
    for (int i = 0; i < noktalar.length; i++) {
      final LatLng nokta = noktalar[i];
      batch.insert('sulama_noktalari', <String, Object?>{
        'sira': i,
        'lat': nokta.latitude,
        'lng': nokta.longitude,
      });
    }
    await batch.commit(noResult: true);
  }
}

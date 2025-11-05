import 'package:benim_ilk_uygulamam/features/ai/depocular/sensor_sqlite_deposu.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/nova_ai_karari.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/sensor_olcumu.dart';
import 'package:benim_ilk_uygulamam/features/ai/nova_ai_yoneticisi.dart';

/// Nova AI karar ?retim servis katman?.
class NovaAiServisi {
  final SensorSqliteDeposu sensorDeposu;
  final NovaAiYoneticisi yonetici;
  bool _modelHazirlandi = false;
  NovaAiServisi({required this.sensorDeposu, required this.yonetici});

  Future<void> hazirla() async {
    if (_modelHazirlandi) {
      return;
    }
    await yonetici.hazirlaModel();
    _modelHazirlandi = true;
  }

  Future<NovaAiKarari> analizEt({required SensorOlcumu olcum, bool kaydet = true}) async {
    await hazirla();
    if (kaydet) {
      await sensorDeposu.kaydetOlcum(olcum: olcum);
    }
    final NovaAiKarari karar = yonetici.analizEt(olcum: olcum);
    return karar;
  }

  Future<NovaAiKarari?> analizEtSonKayit() async {
    final SensorOlcumu? sonOlcum = await sensorDeposu.getirSonOlcum();
    if (sonOlcum == null) {
      return null;
    }
    final NovaAiKarari karar = await analizEt(olcum: sonOlcum, kaydet: false);
    return karar;
  }

  Future<List<NovaAiKarari>> analizEtToplu({int limit = 5}) async {
    await hazirla();
    final List<SensorOlcumu> olcumler = await sensorDeposu.getirSonOlcumler(limit: limit);
    final List<NovaAiKarari> kararlar = olcumler.map((SensorOlcumu olcum) {
      final NovaAiKarari karar = yonetici.analizEt(olcum: olcum);
      return karar;
    }).toList();
    return kararlar;
  }
}

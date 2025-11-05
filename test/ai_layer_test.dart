import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:benim_ilk_uygulamam/core/veritabani/veritabani_yardimcisi.dart';
import 'package:benim_ilk_uygulamam/features/ai/depocular/sensor_sqlite_deposu.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/nova_ai_karari.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/sensor_olcumu.dart';
import 'package:benim_ilk_uygulamam/features/ai/nova_ai_servisi.dart';
import 'package:benim_ilk_uygulamam/features/ai/nova_ai_yoneticisi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Nova AI servisi y?ksek nemde sulamay? ertelemeyi ?nerir', () async {
    final Directory geciciDizin = await Directory.systemTemp.createTemp('ai_test_db');
    addTearDown(() async {
      if (await geciciDizin.exists()) {
        await geciciDizin.delete(recursive: true);
      }
    });
    final VeritabaniYardimcisi yardimci = VeritabaniYardimcisi();
    await yardimci.ac(testDizini: geciciDizin.path);
    final SensorSqliteDeposu depo = SensorSqliteDeposu(veritabaniYardimcisi: yardimci);
    final NovaAiServisi servis = NovaAiServisi(sensorDeposu: depo, yonetici: NovaAiYoneticisi());
    final SensorOlcumu olcum = SensorOlcumu(
      toprakNemiYuzde: 78.0,
      toprakSicakligiSantigrat: 9.0,
      havaSicakligiSantigrat: 18.0,
      isikSeviyesiLuks: 1100.0,
      bagilNemYuzde: 60.0,
      olcumZamani: DateTime.now(),
      kaynak: 'test',
    );
    final NovaAiKarari karar = await servis.analizEt(olcum: olcum);
    expect(karar.sulamaErtelensin, isTrue);
    expect(karar.ikonKimligi, 'ikon_su_damlasi');
    expect(karar.etiketler.contains('Sulama Ertelensin'), isTrue);
    expect(karar.mesaj.contains('Sulama'), isTrue);
  });

  test('Nova AI servisi toplu analizde ?oklu kay?t ?retir', () async {
    final Directory geciciDizin = await Directory.systemTemp.createTemp('ai_test_db_toplu');
    addTearDown(() async {
      if (await geciciDizin.exists()) {
        await geciciDizin.delete(recursive: true);
      }
    });
    final VeritabaniYardimcisi yardimci = VeritabaniYardimcisi();
    await yardimci.ac(testDizini: geciciDizin.path);
    final SensorSqliteDeposu depo = SensorSqliteDeposu(veritabaniYardimcisi: yardimci);
    final NovaAiServisi servis = NovaAiServisi(sensorDeposu: depo, yonetici: NovaAiYoneticisi());
    final List<SensorOlcumu> olcumler = <SensorOlcumu>[
      SensorOlcumu(
        toprakNemiYuzde: 45.0,
        toprakSicakligiSantigrat: 16.0,
        havaSicakligiSantigrat: 20.0,
        isikSeviyesiLuks: 1800.0,
        bagilNemYuzde: 50.0,
        olcumZamani: DateTime.now().subtract(const Duration(minutes: 10)),
        kaynak: 'test',
      ),
      SensorOlcumu(
        toprakNemiYuzde: 75.0,
        toprakSicakligiSantigrat: 8.0,
        havaSicakligiSantigrat: 15.0,
        isikSeviyesiLuks: 800.0,
        bagilNemYuzde: 70.0,
        olcumZamani: DateTime.now(),
        kaynak: 'test',
      ),
    ];
    for (final SensorOlcumu olcum in olcumler) {
      await servis.analizEt(olcum: olcum);
    }
    final List<NovaAiKarari> kararlar = await servis.analizEtToplu(limit: 5);
    expect(kararlar.length, greaterThanOrEqualTo(2));
  });
}

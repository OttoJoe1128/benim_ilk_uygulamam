import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:benim_ilk_uygulamam/core/veritabani/veritabani_yardimcisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_baglantisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_kuyruk_yoneticisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_senkron_servisi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('?evrimd??? yay?n kuyru?u kay?t ekler ve kopyalar? ?nler', () async {
    final Directory geciciDizin = await Directory.systemTemp.createTemp('mqtt_kuyruk_testi');
    addTearDown(() async {
      if (await geciciDizin.exists()) {
        await geciciDizin.delete(recursive: true);
      }
    });
    final VeritabaniYardimcisi yardimci = VeritabaniYardimcisi();
    await yardimci.ac(testDizini: geciciDizin.path);
    final MqttKuyrukYoneticisi kuyruk = MqttKuyrukYoneticisi(veritabaniYardimcisi: yardimci);
    final MqttBaglantiDurumDenetleyici durum = MqttBaglantiDurumDenetleyici();
    final MqttSenkronServisi servis = MqttSenkronServisi(
      baglanti: const MqttBaglantisi(sunucuAdresi: 'test-broker', sunucuPortu: 1883, senkronKonu: 'test/kuyruk', istemciKimligi: 'test-istemci', keepAliveSaniye: 5),
      kuyrukYoneticisi: kuyruk,
      durumDenetleyici: durum,
    );
    await servis.yayinla(veri: '{"sensor":"nem","deger":72}');
    final List<SenkronKaydi> kayitlar = await kuyruk.getirBekleyenler();
    expect(kayitlar.length, 1);
    await servis.yayinla(veri: '{"sensor":"nem","deger":72}');
    final List<SenkronKaydi> kayitlarTekrar = await kuyruk.getirBekleyenler();
    expect(kayitlarTekrar.length, 1);
    expect(durum.state.asama, MqttBaglantiAsamasi.baglantisiz);
  });
}

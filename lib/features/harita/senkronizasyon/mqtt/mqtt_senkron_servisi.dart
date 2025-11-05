import 'dart:async';
import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_baglantisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_kuyruk_yoneticisi.dart';

/// MQTT ba?lant? durumlar?n? temsil eden enum.
enum MqttBaglantiAsamasi { baglantisiz, baglaniyor, baglandi, hatali }

/// Riverpod ?zerinden UI'a bildirilen MQTT ba?lant? durumu modeli.
class MqttBaglantiDurumu {
  final MqttBaglantiAsamasi asama;
  final String mesaj;
  const MqttBaglantiDurumu({required this.asama, required this.mesaj});
}

/// MQTT ba?lant? durumunu y?neten StateNotifier.
class MqttBaglantiDurumDenetleyici extends StateNotifier<MqttBaglantiDurumu> {
  MqttBaglantiDurumDenetleyici() : super(const MqttBaglantiDurumu(asama: MqttBaglantiAsamasi.baglantisiz, mesaj: 'Ba?lant? bekleniyor'));

  void guncelleBaglaniyor() {
    state = const MqttBaglantiDurumu(asama: MqttBaglantiAsamasi.baglaniyor, mesaj: 'MQTT ba?lant?s? kuruluyor');
  }

  void guncelleBaglandi() {
    state = const MqttBaglantiDurumu(asama: MqttBaglantiAsamasi.baglandi, mesaj: 'MQTT ba?l?');
  }

  void guncelleKoptu({String mesaj = 'MQTT ba?lant?s? koptu'}) {
    state = MqttBaglantiDurumu(asama: MqttBaglantiAsamasi.baglantisiz, mesaj: mesaj);
  }

  void guncelleHata({required String mesaj}) {
    state = MqttBaglantiDurumu(asama: MqttBaglantiAsamasi.hatali, mesaj: mesaj);
  }
}

/// Uygulama genelinde MQTT senkronizasyonunu y?r?ten servis.
class MqttSenkronServisi {
  final MqttBaglantisi baglanti;
  final MqttKuyrukYoneticisi kuyrukYoneticisi;
  final MqttBaglantiDurumDenetleyici durumDenetleyici;
  final StreamController<String> _gelenMesajDenetleyici = StreamController<String>.broadcast();
  ReceivePort? _anaPort;
  StreamSubscription<dynamic>? _portDinleyici;
  Isolate? _isolate;
  SendPort? _komutPortu;
  bool _abonelikKuruldu = false;
  MqttSenkronServisi({required this.baglanti, required this.kuyrukYoneticisi, required this.durumDenetleyici});

  Future<void> baslat() async {
    if (_komutPortu != null) {
      return;
    }
    durumDenetleyici.guncelleBaglaniyor();
    final ReceivePort yeniPort = ReceivePort();
    _anaPort = yeniPort;
    final Completer<SendPort> portTamamlayici = Completer<SendPort>();
    _portDinleyici = yeniPort.listen((dynamic mesaj) async {
      if (mesaj is SendPort && !portTamamlayici.isCompleted) {
        portTamamlayici.complete(mesaj);
        return;
      }
      await _yorumlaIsolateMesaji(mesaj: mesaj);
    });
    final Isolate yeniIsolate = await Isolate.spawn<_IsolateBaglantiVerisi>(
      _calistirIsolate,
      _IsolateBaglantiVerisi(
        anaPort: yeniPort.sendPort,
        sunucuAdresi: baglanti.sunucuAdresi,
        sunucuPortu: baglanti.sunucuPortu,
        konu: baglanti.senkronKonu,
        istemciKimligi: baglanti.istemciKimligi,
        keepAlive: baglanti.keepAliveSaniye,
      ),
    );
    _isolate = yeniIsolate;
    _komutPortu = await portTamamlayici.future;
    await _gonderKomut(komut: const _IsolateKomutu(tur: _IslemTuru.baglan, icerik: ''));
  }

  Future<void> yayinla({required String veri}) async {
    if (_komutPortu == null) {
      await kuyrukYoneticisi.ekleIslem(payload: veri);
      return;
    }
    await _gonderKomut(komut: _IsolateKomutu(tur: _IslemTuru.yayinla, icerik: veri));
  }

  Future<void> kopar() async {
    if (_komutPortu != null) {
      await _gonderKomut(komut: const _IsolateKomutu(tur: _IslemTuru.kapat, icerik: ''));
    }
    _temizleIsolateKaynaklari();
    durumDenetleyici.guncelleKoptu();
  }

  Stream<String> dinleGelenMesajlar() {
    return _gelenMesajDenetleyici.stream;
  }

  Future<void> kuyruguBosalt() async {
    final List<SenkronKaydi> kayitlar = await kuyrukYoneticisi.getirBekleyenler();
    for (final SenkronKaydi kayit in kayitlar) {
      await yayinla(veri: kayit.payload);
      await kuyrukYoneticisi.isaretleGonderildi(id: kayit.id);
    }
  }

  Future<void> ekleAcikHavaVerisi({required String payload}) async {
    await yayinla(veri: payload);
  }

  Future<void> _gonderKomut({required _IsolateKomutu komut}) async {
    if (_komutPortu == null) {
      await kuyrukYoneticisi.ekleIslem(payload: komut.icerik);
      return;
    }
    _komutPortu!.send(komut);
  }

  Future<void> _yorumlaIsolateMesaji({required dynamic mesaj}) async {
    if (mesaj is Map<String, Object?>) {
      final String tur = mesaj['tur']! as String;
      if (tur == 'durum') {
        final String detay = mesaj['detay']! as String;
        await _isleDurum(detay: detay);
        return;
      }
      if (tur == 'mesaj') {
        final String icerik = mesaj['detay']! as String;
        _gelenMesajDenetleyici.add(icerik);
        return;
      }
      if (tur == 'baglandi') {
        _abonelikKuruldu = true;
        durumDenetleyici.guncelleBaglandi();
        return;
      }
    }
    if (mesaj == null) {
      durumDenetleyici.guncelleKoptu();
      _temizleIsolateKaynaklari();
    }
  }

  Future<void> _isleDurum({required String detay}) async {
    if (detay == 'baglanildi') {
      durumDenetleyici.guncelleBaglandi();
      if (!_abonelikKuruldu) {
        await _gonderKomut(komut: const _IsolateKomutu(tur: _IslemTuru.aboneOl, icerik: ''));
        _abonelikKuruldu = true;
      }
      await kuyruguBosalt();
      return;
    }
    if (detay == 'koptu') {
      durumDenetleyici.guncelleKoptu();
      return;
    }
    durumDenetleyici.guncelleHata(mesaj: detay);
  }

  void _temizleIsolateKaynaklari() {
    _komutPortu = null;
    _abonelikKuruldu = false;
    _portDinleyici?.cancel();
    _portDinleyici = null;
    _anaPort?.close();
    _anaPort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}

final StateNotifierProvider<MqttBaglantiDurumDenetleyici, MqttBaglantiDurumu> mqttBaglantiDurumuProvider =
    StateNotifierProvider<MqttBaglantiDurumDenetleyici, MqttBaglantiDurumu>((Ref ref) {
  return MqttBaglantiDurumDenetleyici();
});

enum _IslemTuru { baglan, yayinla, kapat, aboneOl }

class _IsolateKomutu {
  final _IslemTuru tur;
  final String icerik;
  const _IsolateKomutu({required this.tur, required this.icerik});
}

class _IsolateBaglantiVerisi {
  final SendPort anaPort;
  final String sunucuAdresi;
  final int sunucuPortu;
  final String konu;
  final String istemciKimligi;
  final int keepAlive;
  const _IsolateBaglantiVerisi({required this.anaPort, required this.sunucuAdresi, required this.sunucuPortu, required this.konu, required this.istemciKimligi, required this.keepAlive});
}

void _calistirIsolate(_IsolateBaglantiVerisi veri) {
  final ReceivePort komutPort = ReceivePort();
  veri.anaPort.send(komutPort.sendPort);
  MqttServerClient? istemci;
  komutPort.listen((dynamic mesaj) async {
    if (mesaj is _IsolateKomutu) {
      final MqttBaglantisi baglanti = MqttBaglantisi(sunucuAdresi: veri.sunucuAdresi, sunucuPortu: veri.sunucuPortu, senkronKonu: veri.konu, istemciKimligi: veri.istemciKimligi, keepAliveSaniye: veri.keepAlive);
      if (mesaj.tur == _IslemTuru.baglan) {
        istemci = await _baglanIslemi(baglanti: baglanti, anaPort: veri.anaPort);
        return;
      }
      if (mesaj.tur == _IslemTuru.yayinla) {
        await _yayinlaIslemi(istemci: istemci, veri: mesaj.icerik, baglanti: baglanti, anaPort: veri.anaPort);
        return;
      }
      if (mesaj.tur == _IslemTuru.aboneOl) {
        await _abonelikIslemi(istemci: istemci, baglanti: baglanti, anaPort: veri.anaPort);
        return;
      }
      if (mesaj.tur == _IslemTuru.kapat) {
        await _kapatIslemi(istemci: istemci, anaPort: veri.anaPort);
      }
    }
  });
}

Future<MqttServerClient?> _baglanIslemi({required MqttBaglantisi baglanti, required SendPort anaPort}) async {
  try {
    final MqttServerClient istemci = baglanti.olusturIstemci();
    await istemci.connect();
    istemci.pongCallback = () {};
    istemci.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? mesajlar) {
      if (mesajlar == null) {
        return;
      }
      for (final MqttReceivedMessage<MqttMessage?> mesaj in mesajlar) {
        final MqttPublishMessage? icerik = mesaj.payload as MqttPublishMessage?;
        if (icerik == null) {
          continue;
        }
        final String metin = MqttPublishPayload.bytesToStringAsString(icerik.payload.message);
        anaPort.send(<String, Object?>{'tur': 'mesaj', 'detay': metin});
      }
    });
    istemci.connectionStatus?.onDisconnect = () {
      anaPort.send(<String, Object?>{'tur': 'durum', 'detay': 'koptu'});
    };
    anaPort.send(<String, Object?>{'tur': 'durum', 'detay': 'baglanildi'});
    return istemci;
  } catch (Object hata) {
    anaPort.send(<String, Object?>{'tur': 'durum', 'detay': 'Hata: ${hata.toString()}'});
    return null;
  }
}

Future<void> _yayinlaIslemi({required MqttServerClient? istemci, required String veri, required MqttBaglantisi baglanti, required SendPort anaPort}) async {
  if (istemci == null) {
    anaPort.send(<String, Object?>{'tur': 'durum', 'detay': 'Istemci yokken yay?n denendi'});
    return;
  }
  final MqttClientPayloadBuilder yuk = MqttClientPayloadBuilder();
  yuk.addString(veri);
  istemci.publishMessage(baglanti.senkronKonu, MqttQos.atLeastOnce, yuk.payload!);
}

Future<void> _abonelikIslemi({required MqttServerClient? istemci, required MqttBaglantisi baglanti, required SendPort anaPort}) async {
  if (istemci == null) {
    anaPort.send(<String, Object?>{'tur': 'durum', 'detay': 'abonelik i?in istemci yok'});
    return;
  }
  istemci.subscribe(baglanti.senkronKonu, MqttQos.atLeastOnce);
  anaPort.send(<String, Object?>{'tur': 'baglandi', 'detay': 'abonelik aktif'});
}

Future<void> _kapatIslemi({required MqttServerClient? istemci, required SendPort anaPort}) async {
  if (istemci != null && istemci.connectionStatus?.state == MqttConnectionState.connected) {
    await istemci.disconnect();
  }
  anaPort.send(null);
}

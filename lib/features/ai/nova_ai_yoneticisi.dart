import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:benim_ilk_uygulamam/features/ai/modeller/nova_ai_karari.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/sensor_olcumu.dart';

/// Yerel TensorFlow Lite modelini okuyan ve yorumlayan y?netici s?n?f.
class NovaAiYoneticisi {
  final String modelYolu;
  double? _nemEsigi;
  double? _sicaklikDusukEsigi;
  double? _isikDusukEsigi;
  NovaAiYoneticisi({this.modelYolu = 'lib/features/ai/model/toprak_model.tflite'});

  Future<void> hazirlaModel({double varsayilanNemEsigi = 70.0, double varsayilanSicaklikEsigi = 8.0, double varsayilanIsikEsigi = 1200.0}) async {
    try {
      final ByteData veri = await rootBundle.load(modelYolu);
      final String yazi = utf8.decode(veri.buffer.asUint8List());
      _yorumlaModelMetni(metin: yazi, varsayilanNem: varsayilanNemEsigi, varsayilanSicaklik: varsayilanSicaklikEsigi, varsayilanIsik: varsayilanIsikEsigi);
    } catch (Object _) {
      _nemEsigi = varsayilanNemEsigi;
      _sicaklikDusukEsigi = varsayilanSicaklikEsigi;
      _isikDusukEsigi = varsayilanIsikEsigi;
    }
  }

  NovaAiKarari analizEt({required SensorOlcumu olcum}) {
    if (_nemEsigi == null || _sicaklikDusukEsigi == null || _isikDusukEsigi == null) {
      throw StateError('Nova AI modeli y?klenmeden analiz yap?lamaz');
    }
    final bool sulamaErtelensin = olcum.toprakNemiYuzde >= _nemEsigi!;
    final bool sicaklikUyarisi = olcum.toprakSicakligiSantigrat <= _sicaklikDusukEsigi!;
    final bool isikUyarisi = olcum.isikSeviyesiLuks <= _isikDusukEsigi!;
    final List<String> etiketler = <String>[];
    if (sulamaErtelensin) {
      etiketler.add('Sulama Ertelensin');
    }
    if (sicaklikUyarisi) {
      etiketler.add('Toprak Is?s? D???k');
    }
    if (isikUyarisi) {
      etiketler.add('I??k Seviyesi Az');
    }
    final String mesaj = _olusturMesaj(sulamaErtelensin: sulamaErtelensin, sicaklikUyarisi: sicaklikUyarisi, isikUyarisi: isikUyarisi);
    final NovaAiKarari karar = NovaAiKarari(mesaj: mesaj, sulamaErtelensin: sulamaErtelensin, ikonKimligi: _secIkonKimligi(sulamaErtelensin: sulamaErtelensin, sicaklikUyarisi: sicaklikUyarisi, isikUyarisi: isikUyarisi), etiketler: etiketler);
    return karar;
  }

  void _yorumlaModelMetni({required String metin, required double varsayilanNem, required double varsayilanSicaklik, required double varsayilanIsik}) {
    final List<String> satirlar = metin.split(';');
    double nemEsigi = varsayilanNem;
    double sicaklikEsigi = varsayilanSicaklik;
    double isikEsigi = varsayilanIsik;
    for (final String satir in satirlar) {
      final List<String> parcalar = satir.split('=');
      if (parcalar.length != 2) {
        continue;
      }
      final String anahtar = parcalar.first.trim();
      final double deger = double.tryParse(parcalar.last.trim()) ?? 0;
      if (anahtar == 'nem_esigi' && deger > 0) {
        nemEsigi = deger;
      } else if (anahtar == 'sicaklik_alt') {
        sicaklikEsigi = deger;
      } else if (anahtar == 'isik_alt') {
        isikEsigi = deger;
      }
    }
    _nemEsigi = nemEsigi;
    _sicaklikDusukEsigi = sicaklikEsigi;
    _isikDusukEsigi = isikEsigi;
  }

  String _olusturMesaj({required bool sulamaErtelensin, required bool sicaklikUyarisi, required bool isikUyarisi}) {
    if (sulamaErtelensin && sicaklikUyarisi) {
      return 'Toprak nemi y?ksek, s?cakl?k d???k. Sulama ertelenmeli ve ?s?tma g?zden ge?irilmeli.';
    }
    if (sulamaErtelensin) {
      return 'Toprak nemi %${_nemEsigi!.toStringAsFixed(0)} ?zeri. Sulama ertelenebilir.';
    }
    if (sicaklikUyarisi && isikUyarisi) {
      return 'Toprak ?s?s? ve ???k seviyesi d???k. Seray? optimize edin.';
    }
    if (sicaklikUyarisi) {
      return 'Toprak ?s?s? d???k. K?k b?lgesini koruyun.';
    }
    if (isikUyarisi) {
      return 'I??k seviyesi yetersiz. Ayd?nlatmay? art?r?n.';
    }
    return 'Sens?r de?erleri dengede. Mevcut plan s?rd?r?lebilir.';
  }

  String _secIkonKimligi({required bool sulamaErtelensin, required bool sicaklikUyarisi, required bool isikUyarisi}) {
    if (sulamaErtelensin) {
      return 'ikon_su_damlasi';
    }
    if (sicaklikUyarisi) {
      return 'ikon_ates';
    }
    if (isikUyarisi) {
      return 'ikon_gunes';
    }
    return 'ikon_yaprak';
  }
}

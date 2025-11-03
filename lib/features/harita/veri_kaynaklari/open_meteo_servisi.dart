import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:benim_ilk_uygulamam/features/ai/modeller/nova_ai_karari.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/sensor_olcumu.dart';
import 'package:benim_ilk_uygulamam/features/ai/nova_ai_servisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/modeller/open_meteo_verisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_senkron_servisi.dart';

/// Open-Meteo API'sinden veri ?ekip Nova ekosistemine aktaran servis.
class OpenMeteoServisi {
  final http.Client httpIstemcisi;
  final MqttSenkronServisi mqttSenkronServisi;
  final NovaAiServisi novaAiServisi;
  const OpenMeteoServisi({required this.httpIstemcisi, required this.mqttSenkronServisi, required this.novaAiServisi});

  Future<OpenMeteoVerisi> getirAnlikVeri({required double enlem, required double boylam}) async {
    final Uri istek = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$enlem&longitude=$boylam&current=temperature_2m,relative_humidity_2m,soil_temperature_0cm,soil_moisture_0_1m,shortwave_radiation&timezone=auto');
    final http.Response yanit = await httpIstemcisi.get(istek);
    if (yanit.statusCode != 200) {
      throw Exception('Open-Meteo iste?i ba?ar?s?z kod: ${yanit.statusCode}');
    }
    final Map<String, dynamic> cevap = jsonDecode(yanit.body) as Map<String, dynamic>;
    final Map<String, dynamic> guncel = (cevap['current'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final double havaSicakligi = (guncel['temperature_2m'] as num?)?.toDouble() ?? 20.0;
    final double bagilNem = (guncel['relative_humidity_2m'] as num?)?.toDouble() ?? 55.0;
    final double toprakSicakligi = (guncel['soil_temperature_0cm'] as num?)?.toDouble() ?? 18.0;
    final double toprakNemi = ((guncel['soil_moisture_0_1m'] as num?)?.toDouble() ?? 0.25) * 100;
    final double isikSeviyesi = (guncel['shortwave_radiation'] as num?)?.toDouble() ?? 900.0;
    final String zamanMetni = (guncel['time'] as String?) ?? DateTime.now().toIso8601String();
    final DateTime zaman = DateTime.tryParse(zamanMetni) ?? DateTime.now();
    final OpenMeteoVerisi veri = OpenMeteoVerisi(havaSicakligiSantigrat: havaSicakligi, bagilNemYuzde: bagilNem, toprakSicakligiSantigrat: toprakSicakligi, toprakNemiOran: toprakNemi, isikSeviyesiLuks: isikSeviyesi, olcumZamani: zaman);
    return veri;
  }

  Future<OpenMeteoAnalizSonucu> getirVeriVeAnalizEt({required double enlem, required double boylam}) async {
    final OpenMeteoVerisi veri = await getirAnlikVeri(enlem: enlem, boylam: boylam);
    final SensorOlcumu olcum = SensorOlcumu(toprakNemiYuzde: veri.toprakNemiOran, toprakSicakligiSantigrat: veri.toprakSicakligiSantigrat, havaSicakligiSantigrat: veri.havaSicakligiSantigrat, isikSeviyesiLuks: veri.isikSeviyesiLuks, bagilNemYuzde: veri.bagilNemYuzde, olcumZamani: veri.olcumZamani, kaynak: 'open_meteo');
    final Map<String, Object> yuk = <String, Object>{
      'kaynak': 'open_meteo',
      'havaSicakligi': veri.havaSicakligiSantigrat,
      'bagilNem': veri.bagilNemYuzde,
      'toprakSicakligi': veri.toprakSicakligiSantigrat,
      'toprakNemi': veri.toprakNemiOran,
      'isikLuks': veri.isikSeviyesiLuks,
      'zaman': veri.olcumZamani.toIso8601String(),
    };
    await mqttSenkronServisi.yayinla(veri: jsonEncode(yuk));
    final NovaAiKarari karar = await novaAiServisi.analizEt(olcum: olcum);
    return OpenMeteoAnalizSonucu(veri: veri, karar: karar);
  }
}

/// Open-Meteo verisi ile Nova AI karar?n? birlikte ta??yan veri modeli.
class OpenMeteoAnalizSonucu {
  final OpenMeteoVerisi veri;
  final NovaAiKarari karar;
  const OpenMeteoAnalizSonucu({required this.veri, required this.karar});
}

// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/entities/bitki_analiz_sonucu.dart';

class PlantIdUzakVeriKaynagi {
  final Dio dio;
  PlantIdUzakVeriKaynagi({required this.dio});
  Future<BitkiAnalizSonucu> analizEt({required String goruntuDosyaYolu}) async {
    final String? apiAnahtari = dotenv.maybeGet('PLANT_ID_API_KEY');
    if (apiAnahtari == null || apiAnahtari.isEmpty) {
      throw Exception('PLANT_ID_API_KEY tanımsız');
    }
    final String base64Gorsel = base64Encode(await File(goruntuDosyaYolu).readAsBytes());
    final Map<String, Object> govde = <String, Object>{
      'images': <String>[base64Gorsel],
      'modifiers': <String>['crops_fast', 'similar_images'],
      'plant_language': 'tr',
      'plant_details': <String>['common_names', 'url', 'name_authority', 'wiki_description', 'taxonomy', 'synonyms']
    };
    final Response<dynamic> yanit = await dio.post(
      'https://api.plant.id/v3/identification',
      data: jsonEncode(govde),
      options: Options(headers: <String, String>{'Content-Type': 'application/json', 'Api-Key': apiAnahtari}),
    );
    final dynamic veri = yanit.data;
    final List<dynamic> oneriler = (veri['suggestions'] as List<dynamic>? ?? <dynamic>[]);
    if (oneriler.isEmpty) {
      return const BitkiAnalizSonucu(turAdi: 'Bilinmiyor', guvenPuani: 0, aciklama: '', etiketler: <String>[]);
    }
    final dynamic ilk = oneriler.first;
    final String tur = (ilk['plant_name'] as String?) ?? 'Bilinmiyor';
    final double puan = (ilk['probability'] as num?)?.toDouble() ?? 0.0;
    final String aciklama = (ilk['plant_details']?['wiki_description']?['value'] as String?) ?? '';
    final List<String> etiketler = ((ilk['plant_details']?['common_names'] as List<dynamic>?) ?? <dynamic>[]).map((dynamic e) => e.toString()).toList();
    return BitkiAnalizSonucu(turAdi: tur, guvenPuani: puan, aciklama: aciklama, etiketler: etiketler);
  }
}

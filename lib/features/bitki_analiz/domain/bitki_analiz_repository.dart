// ignore_for_file: public_member_api_docs

import 'entities/bitki_analiz_sonucu.dart';

abstract class BitkiAnalizHavuzu {
  Future<BitkiAnalizSonucu> analizEt({required String goruntuDosyaYolu});
}

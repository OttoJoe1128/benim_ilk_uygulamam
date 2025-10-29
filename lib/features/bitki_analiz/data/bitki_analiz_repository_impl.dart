// ignore_for_file: public_member_api_docs

import '../domain/bitki_analiz_repository.dart';
import '../domain/entities/bitki_analiz_sonucu.dart';
import 'plantid_remote_data_source.dart';

class BitkiAnalizHavuzuGercek implements BitkiAnalizHavuzu {
  final PlantIdUzakVeriKaynagi uzakKaynagi;
  BitkiAnalizHavuzuGercek({required this.uzakKaynagi});
  @override
  Future<BitkiAnalizSonucu> analizEt({required String goruntuDosyaYolu}) {
    return uzakKaynagi.analizEt(goruntuDosyaYolu: goruntuDosyaYolu);
  }
}

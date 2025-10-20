import '../entities/tani_sonucu.dart';

abstract class BitkiTaniDeposu {
  Future<List<TaniSonucu>> yapTani({required String goruntuYolu});
}

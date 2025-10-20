import '../../domain/entities/tani_sonucu.dart';
import '../../domain/repositories/bitki_tani_deposu.dart';
import '../datasources/model_veri_kaynagi.dart';

class BitkiTaniDeposuImpl implements BitkiTaniDeposu {
  final ModelVeriKaynagi modelVeriKaynagi;
  const BitkiTaniDeposuImpl({required this.modelVeriKaynagi});
  @override
  Future<List<TaniSonucu>> yapTani({required String goruntuYolu}) {
    return modelVeriKaynagi.calistirModel(goruntuYolu: goruntuYolu);
  }
}

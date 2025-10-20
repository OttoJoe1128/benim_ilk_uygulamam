import '../entities/tani_sonucu.dart';
import '../repositories/bitki_tani_deposu.dart';

class TaniYapGirdisi {
  final String goruntuYolu;
  const TaniYapGirdisi({required this.goruntuYolu});
}

class TaniYapSonucu {
  final List<TaniSonucu> sonuclar;
  const TaniYapSonucu({required this.sonuclar});
}

class TaniYapUseCase {
  final BitkiTaniDeposu depo;
  const TaniYapUseCase({required this.depo});
  Future<TaniYapSonucu> calistir({required TaniYapGirdisi girdi}) async {
    final List<TaniSonucu> sonuclar = await depo.yapTani(goruntuYolu: girdi.goruntuYolu);
    return TaniYapSonucu(sonuclar: sonuclar);
  }
}

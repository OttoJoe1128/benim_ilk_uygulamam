import '../../domain/entities/tani_sonucu.dart';

abstract class ModelVeriKaynagi {
  Future<List<TaniSonucu>> calistirModel({required String goruntuYolu});
}

class SahteModelVeriKaynagi implements ModelVeriKaynagi {
  @override
  Future<List<TaniSonucu>> calistirModel({required String goruntuYolu}) async {
    return <TaniSonucu>[
      const TaniSonucu(etiket: 'Saglikli', olasilik: 0.85),
      const TaniSonucu(etiket: 'Mantar Hastaligi', olasilik: 0.10),
      const TaniSonucu(etiket: 'Bilinmiyor', olasilik: 0.05),
    ];
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/tani_yap.dart';
import '../durumlar/tani_durumu.dart';
import '../../../core/di/bagimliliklar.dart';

final StateNotifierProvider<TaniDenetleyicisi, TaniDurumu> taniDenetleyicisiProvider = StateNotifierProvider<TaniDenetleyicisi, TaniDurumu>((Ref ref) {
  return TaniDenetleyicisi(kullan: bagimlilikCozumleyici<TaniYapUseCase>());
});

class TaniDenetleyicisi extends StateNotifier<TaniDurumu> {
  final TaniYapUseCase kullan;
  TaniDenetleyicisi({required this.kullan}) : super(const TaniDurumu.baslangic());
  Future<void> baslatTani({required String goruntuYolu}) async {
    state = const TaniDurumu.yukleniyor();
    try {
      final TaniYapSonucu sonuc = await kullan.calistir(girdi: TaniYapGirdisi(goruntuYolu: goruntuYolu));
      final List<String> etiketler = sonuc.sonuclar.map((e) => '${e.etiket} (%${(e.olasilik * 100).toStringAsFixed(0)})').toList(growable: false);
      state = TaniDurumu.basari(etiketler: etiketler);
    } catch (e) {
      state = TaniDurumu.hata(mesaj: e.toString());
    }
  }
}

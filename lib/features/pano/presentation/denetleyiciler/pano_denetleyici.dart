import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/sozlesmeler/pano_deposu.dart';
import '../../../domain/varliklar/pano.dart';
import '../durum/pano_durumu.dart';

class PanoDenetleyici extends StateNotifier<PanoDurumu> {
  final PanoDeposu panoDeposu;
  PanoDenetleyici({required this.panoDeposu}) : super(const PanoDurumu.yukleniyor());

  Future<void> getirPanolari() async {
    try {
      state = const PanoDurumu.yukleniyor();
      final List<PanoCikti> ciktiListesi = await panoDeposu.getirPanolari();
      final List<Pano> panolar = ciktiListesi
          .map((PanoCikti c) => Pano(id: c.id, baslik: c.baslik, olusturulma: c.olusturulma, bitis: c.bitis))
          .toList(growable: false);
      state = PanoDurumu.basarili(panolar);
    } catch (e) {
      state = PanoDurumu.basarisiz(e.toString());
    }
  }

  Future<void> olusturPano({required String baslik, required DateTime bitis}) async {
    try {
      final PanoCikti yeni = await panoDeposu.olusturPano(PanoGirdi(baslik: baslik, bitis: bitis));
      final Pano pano = Pano(id: yeni.id, baslik: yeni.baslik, olusturulma: yeni.olusturulma, bitis: yeni.bitis);
      final List<Pano> guncel = <Pano>[pano, ..._mevcutPanolar()];
      state = PanoDurumu.basarili(guncel);
    } catch (e) {
      state = PanoDurumu.basarisiz(e.toString());
    }
  }

  List<Pano> _mevcutPanolar() {
    final PanoDurumu s = state;
    if (s is _Basarili) {
      return s.panolar;
    }
    return <Pano>[];
  }
}

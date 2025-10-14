import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sozlesmeler/sohbet_deposu.dart';
import '../../domain/varliklar/mesaj.dart';
import '../durum/sohbet_durumu.dart';
import '../../../../core/utils/icerik_filtresi.dart';

class SohbetDenetleyici extends StateNotifier<SohbetDurumu> {
  final SohbetDeposu sohbetDeposu;
  final String panoId;
  SohbetDenetleyici({required this.sohbetDeposu, required this.panoId}) : super(const SohbetDurumu.yukleniyor());

  Future<void> getirMesajlari() async {
    try {
      state = const SohbetDurumu.yukleniyor();
      final List<MesajCikti> cikti = await sohbetDeposu.getirMesajlar(panoId);
      final List<Mesaj> liste = cikti
          .map((MesajCikti c) => Mesaj(id: c.id, panoId: c.panoId, icerik: c.icerik, zaman: c.zaman))
          .toList(growable: false);
      state = SohbetDurumu.basarili(liste);
    } catch (e) {
      state = SohbetDurumu.basarisiz(e.toString());
    }
  }

  Future<void> gonderMesaj(String icerik) async {
    try {
      if (IcerikFiltresi.hasUygunsuz(icerik)) {
        final String temiz = IcerikFiltresi.temizle(icerik);
        await sohbetDeposu.ekleMesaj(MesajGirdi(panoId: panoId, icerik: temiz));
      } else {
        await sohbetDeposu.ekleMesaj(MesajGirdi(panoId: panoId, icerik: icerik));
      }
      await getirMesajlari();
    } catch (e) {
      state = SohbetDurumu.basarisiz(e.toString());
    }
  }
}

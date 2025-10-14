import 'package:uuid/uuid.dart';

import '../../domain/sozlesmeler/sohbet_deposu.dart';
import '../../domain/varliklar/mesaj.dart';

class SohbetDeposuBellek implements SohbetDeposu {
  final List<Mesaj> mesajlar;
  final Uuid uuidUretici;
  SohbetDeposuBellek({List<Mesaj>? baslangicMesajlari, Uuid? uuid})
      : mesajlar = baslangicMesajlari ?? <Mesaj>[],
        uuidUretici = uuid ?? const Uuid();

  @override
  Future<List<MesajCikti>> getirMesajlar(String panoId) async {
    final List<Mesaj> liste = mesajlar.where((Mesaj m) => m.panoId == panoId).toList(growable: false);
    final List<MesajCikti> sonuc = liste
        .map((Mesaj m) => MesajCikti(id: m.id, panoId: m.panoId, icerik: m.icerik, zaman: m.zaman))
        .toList(growable: false);
    return sonuc;
  }

  @override
  Future<MesajCikti> ekleMesaj(MesajGirdi girdi) async {
    final String yeniId = uuidUretici.v4();
    final Mesaj yeni = Mesaj(id: yeniId, panoId: girdi.panoId, icerik: girdi.icerik, zaman: DateTime.now());
    mesajlar.add(yeni);
    return MesajCikti(id: yeni.id, panoId: yeni.panoId, icerik: yeni.icerik, zaman: yeni.zaman);
  }

  @override
  Future<void> silMesaj(String mesajId) async {
    mesajlar.removeWhere((Mesaj m) => m.id == mesajId);
  }
}

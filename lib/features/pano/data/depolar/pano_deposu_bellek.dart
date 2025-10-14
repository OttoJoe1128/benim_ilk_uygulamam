import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../domain/sozlesmeler/pano_deposu.dart';
import '../../domain/varliklar/pano.dart';

class PanoZatenVarHatasi implements Exception {
  final String mesaj;
  const PanoZatenVarHatasi(this.mesaj);
  @override
  String toString() => mesaj;
}

class PanoDeposuBellek implements PanoDeposu {
  final List<Pano> panolar;
  final Uuid uuidUretici;
  Timer? _temizlikZamanlayici;
  PanoDeposuBellek({List<Pano>? baslangicPanolari, Uuid? uuid})
      : panolar = baslangicPanolari ?? <Pano>[],
        uuidUretici = uuid ?? const Uuid() {
    _baslatTemizlikZamanlayici();
  }

  @override
  Future<List<PanoCikti>> getirPanolari() async {
    _temizleSuresiDolanlari();
    final List<Pano> aktifPanolar = panolar.where((Pano p) => !p.isSuresiDoldu()).toList(growable: false);
    final List<PanoCikti> sonuc = aktifPanolar
        .map((Pano p) => PanoCikti(id: p.id, baslik: p.baslik, olusturulma: p.olusturulma, bitis: p.bitis))
        .toList(growable: false);
    return sonuc;
  }

  @override
  Future<PanoCikti> olusturPano(PanoGirdi girdi) async {
    _temizleSuresiDolanlari();
    final bool zatenVar = panolar.any((Pano p) => p.baslik == girdi.baslik && !p.isSuresiDoldu());
    if (zatenVar) {
      throw const PanoZatenVarHatasi('Aynı başlığa sahip aktif bir pano zaten var.');
    }
    final String yeniId = uuidUretici.v4();
    final Pano yeni = Pano(id: yeniId, baslik: girdi.baslik, olusturulma: DateTime.now(), bitis: girdi.bitis);
    panolar.add(yeni);
    return PanoCikti(id: yeni.id, baslik: yeni.baslik, olusturulma: yeni.olusturulma, bitis: yeni.bitis);
  }

  @override
  Future<void> silPano(String panoId) async {
    panolar.removeWhere((Pano p) => p.id == panoId);
  }

  void _temizleSuresiDolanlari() {
    panolar.removeWhere((Pano p) => p.isSuresiDoldu());
  }

  void _baslatTemizlikZamanlayici() {
    _temizlikZamanlayici?.cancel();
    _temizlikZamanlayici = Timer.periodic(const Duration(minutes: 1), (_) => _temizleSuresiDolanlari());
  }

  void durdurTemizlikZamanlayici() {
    _temizlikZamanlayici?.cancel();
    _temizlikZamanlayici = null;
  }
}

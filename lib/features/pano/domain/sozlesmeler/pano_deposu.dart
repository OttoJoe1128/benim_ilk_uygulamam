abstract class PanoDeposu {
  Future<List<PanoCikti>> getirPanolari();
  Future<PanoCikti> olusturPano(PanoGirdi girdi);
  Future<void> silPano(String panoId);
}

class PanoGirdi {
  final String baslik;
  final DateTime bitis;
  const PanoGirdi({required this.baslik, required this.bitis});
}

class PanoCikti {
  final String id;
  final String baslik;
  final DateTime olusturulma;
  final DateTime bitis;
  const PanoCikti({required this.id, required this.baslik, required this.olusturulma, required this.bitis});
}

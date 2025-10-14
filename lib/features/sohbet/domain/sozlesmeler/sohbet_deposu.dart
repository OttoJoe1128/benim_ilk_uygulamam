abstract class SohbetDeposu {
  Future<List<MesajCikti>> getirMesajlar(String panoId);
  Future<MesajCikti> ekleMesaj(MesajGirdi girdi);
  Future<void> silMesaj(String mesajId);
}

class MesajGirdi {
  final String panoId;
  final String icerik;
  const MesajGirdi({required this.panoId, required this.icerik});
}

class MesajCikti {
  final String id;
  final String panoId;
  final String icerik;
  final DateTime zaman;
  const MesajCikti({required this.id, required this.panoId, required this.icerik, required this.zaman});
}

// ignore_for_file: public_member_api_docs

abstract class UygulamaHatasi implements Exception {
  String mesaj();
}

class AgHatasi implements UygulamaHatasi {
  final String aciklama;
  AgHatasi(this.aciklama);
  @override
  String mesaj() => 'Ağ hatası: $aciklama';
}

class SunucuHatasi implements UygulamaHatasi {
  final int durumKodu;
  final String aciklama;
  SunucuHatasi({required this.durumKodu, required this.aciklama});
  @override
  String mesaj() => 'Sunucu hatası ($durumKodu): $aciklama';
}

class BeklenmeyenHata implements UygulamaHatasi {
  final String aciklama;
  BeklenmeyenHata(this.aciklama);
  @override
  String mesaj() => 'Beklenmeyen hata: $aciklama';
}

import 'package:nova_agro/features/harita/depocular/senkron_islem_deposu.dart';
import 'package:nova_agro/features/harita/varliklar/senkron_islem.dart';

class SenkronIslemBellekDeposu implements SenkronIslemDeposu {
  final List<SenkronIslem> _islemler = <SenkronIslem>[];
  int _sayac = 0;

  @override
  Future<SenkronIslem> ekleIslem({required SenkronIslem islem}) async {
    final SenkronIslem yeni = islem.kopyala(id: ++_sayac);
    _islemler.add(yeni);
    return yeni;
  }

  @override
  Future<List<SenkronIslem>> getirBekleyenIslemler() async {
    _islemler.sort(
      (SenkronIslem a, SenkronIslem b) =>
          a.olusturmaZamani.compareTo(b.olusturmaZamani),
    );
    return List<SenkronIslem>.from(_islemler);
  }

  @override
  Future<void> silIslem({required int islemId}) async {
    _islemler.removeWhere((SenkronIslem islem) => islem.id == islemId);
  }
}

import 'package:nova_agro/features/harita/varliklar/senkron_islem.dart';

abstract class SenkronIslemDeposu {
  Future<SenkronIslem> ekleIslem({required SenkronIslem islem});
  Future<List<SenkronIslem>> getirBekleyenIslemler();
  Future<void> silIslem({required int islemId});
}

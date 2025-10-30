import 'package:benim_ilk_uygulamam/features/harita/varliklar/parsel.dart';

/// Parsel konum sorgulama sözleşmesi
abstract class ParselKonumDeposu {
  Future<Parsel?> getirParselKonumu({
    required String arsaNo,
    required String adaNo,
    required String parselNo,
  });
}

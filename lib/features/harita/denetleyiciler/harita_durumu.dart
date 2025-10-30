import 'package:benim_ilk_uygulamam/features/harita/varliklar/parsel.dart';

sealed class HaritaDurumu {
  const HaritaDurumu();
}

final class IlkDurum extends HaritaDurumu {
  const IlkDurum();
}

final class YukleniyorDurumu extends HaritaDurumu {
  const YukleniyorDurumu();
}

final class BasariliDurumu extends HaritaDurumu {
  final Parsel seciliParsel;
  const BasariliDurumu({required this.seciliParsel});
}

final class HataDurumu extends HaritaDurumu {
  final String mesaj;
  const HataDurumu({required this.mesaj});
}

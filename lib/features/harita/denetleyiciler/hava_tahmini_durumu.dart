import 'package:nova_agro/features/harita/varliklar/hava_durumu.dart';

sealed class HavaTahminiDurumu {
  const HavaTahminiDurumu();
}

final class HavaTahminiIlkDurum extends HavaTahminiDurumu {
  const HavaTahminiIlkDurum();
}

final class HavaTahminiYukleniyorDurumu extends HavaTahminiDurumu {
  const HavaTahminiYukleniyorDurumu();
}

final class HavaTahminiBasariliDurumu extends HavaTahminiDurumu {
  final HavaDurumu havaDurumu;
  const HavaTahminiBasariliDurumu({required this.havaDurumu});
}

final class HavaTahminiHataDurumu extends HavaTahminiDurumu {
  final String mesaj;
  const HavaTahminiHataDurumu({required this.mesaj});
}

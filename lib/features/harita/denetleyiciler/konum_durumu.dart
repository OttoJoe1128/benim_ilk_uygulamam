import 'package:latlong2/latlong.dart';

sealed class KonumDurumu {
  const KonumDurumu();
}

final class KonumBaslangicDurumu extends KonumDurumu {
  const KonumBaslangicDurumu();
}

final class KonumIzinBekleniyorDurumu extends KonumDurumu {
  const KonumIzinBekleniyorDurumu();
}

final class KonumIzinRedDurumu extends KonumDurumu {
  final String mesaj;
  const KonumIzinRedDurumu({required this.mesaj});
}

final class KonumYukleniyorDurumu extends KonumDurumu {
  const KonumYukleniyorDurumu();
}

final class KonumBasariliDurumu extends KonumDurumu {
  final LatLng kullaniciKonumu;
  const KonumBasariliDurumu({required this.kullaniciKonumu});
}

final class KonumHataDurumu extends KonumDurumu {
  final String mesaj;
  const KonumHataDurumu({required this.mesaj});
}

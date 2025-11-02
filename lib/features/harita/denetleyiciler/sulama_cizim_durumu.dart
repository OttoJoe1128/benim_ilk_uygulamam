import 'package:latlong2/latlong.dart';

class SulamaCizimDurumu {
  final bool isCizimAcik;
  final List<LatLng> noktalar;

  const SulamaCizimDurumu({required this.isCizimAcik, required this.noktalar});

  factory SulamaCizimDurumu.ilk() {
    return const SulamaCizimDurumu(isCizimAcik: false, noktalar: <LatLng>[]);
  }

  SulamaCizimDurumu kopyala({bool? isCizimAcik, List<LatLng>? noktalar}) {
    return SulamaCizimDurumu(
      isCizimAcik: isCizimAcik ?? this.isCizimAcik,
      noktalar: noktalar ?? this.noktalar,
    );
  }
}

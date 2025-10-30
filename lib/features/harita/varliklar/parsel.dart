import 'package:latlong2/latlong.dart';

/// Parsel bilgisi ve sınır geometrisi
class Parsel {
  final String arsaNo;
  final String adaNo;
  final String parselNo;
  final List<LatLng> sinirNoktalari;

  const Parsel({
    required this.arsaNo,
    required this.adaNo,
    required this.parselNo,
    required this.sinirNoktalari,
  });

  LatLng hesaplaMerkez() {
    if (sinirNoktalari.isEmpty) {
      return const LatLng(0.0, 0.0);
    }
    final double ortEnlem =
        sinirNoktalari.map((LatLng p) => p.latitude).reduce((double a, double b) => a + b) /
            sinirNoktalari.length;
    final double ortBoylam =
        sinirNoktalari.map((LatLng p) => p.longitude).reduce((double a, double b) => a + b) /
            sinirNoktalari.length;
    return LatLng(ortEnlem, ortBoylam);
  }
}

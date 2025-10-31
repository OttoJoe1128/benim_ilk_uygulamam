import 'package:latlong2/latlong.dart';

abstract class SulamaCizimDeposu {
  Future<List<LatLng>> getirNoktalar();
  Future<void> kaydetNoktalar({required List<LatLng> noktalar});
}

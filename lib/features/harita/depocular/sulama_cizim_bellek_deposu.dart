import 'package:latlong2/latlong.dart';

import 'package:nova_agro/features/harita/depocular/sulama_cizim_deposu.dart';

class SulamaCizimBellekDeposu implements SulamaCizimDeposu {
  List<LatLng> _noktalar = <LatLng>[];

  @override
  Future<List<LatLng>> getirNoktalar() async {
    return List<LatLng>.unmodifiable(_noktalar);
  }

  @override
  Future<void> kaydetNoktalar({required List<LatLng> noktalar}) async {
    _noktalar = List<LatLng>.from(noktalar);
  }
}

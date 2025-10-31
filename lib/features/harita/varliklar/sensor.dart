import 'package:latlong2/latlong.dart';

class Sensor {
  final String id;
  final String ad;
  final LatLng konum;
  final DateTime olusturmaZamani;

  const Sensor({
    required this.id,
    required this.ad,
    required this.konum,
    required this.olusturmaZamani,
  });

  Sensor kopyala({
    String? id,
    String? ad,
    LatLng? konum,
    DateTime? olusturmaZamani,
  }) {
    return Sensor(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      konum: konum ?? this.konum,
      olusturmaZamani: olusturmaZamani ?? this.olusturmaZamani,
    );
  }
}

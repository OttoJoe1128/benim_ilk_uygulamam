import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class KonumHizmeti {
  Future<bool> isKonumServisiAcil() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> getirKonumIzinDurumu() async {
    return Geolocator.checkPermission();
  }

  Future<LocationPermission> isteKonumIzni() async {
    return Geolocator.requestPermission();
  }

  Future<PermissionStatus> isteArkaPlanIzni() async {
    return Permission.locationAlways.request();
  }

  Future<LatLng> getirGuncelKonum() async {
    final Position pozisyon = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
    return LatLng(pozisyon.latitude, pozisyon.longitude);
  }

  Future<void> acKonumAyarlarini() async {
    await Geolocator.openLocationSettings();
  }
}

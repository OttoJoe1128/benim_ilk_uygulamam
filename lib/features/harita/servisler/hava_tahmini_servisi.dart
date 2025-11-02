import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import 'package:nova_agro/features/harita/varliklar/hava_durumu.dart';

abstract class HavaTahminiServisi {
  Future<HavaDurumu> getirHavaDurumu({required LatLng konum});
}

class OpenMeteoHavaTahminiServisi implements HavaTahminiServisi {
  final Dio dio;
  final Duration cacheSuresi;
  final Map<String, _CacheKaydi> _cache = <String, _CacheKaydi>{};

  OpenMeteoHavaTahminiServisi({
    required this.dio,
    this.cacheSuresi = const Duration(minutes: 10),
  });

  @override
  Future<HavaDurumu> getirHavaDurumu({required LatLng konum}) async {
    final String anahtar = _anahtarUret(konum);
    final DateTime simdi = DateTime.now();
    final _CacheKaydi? kayit = _cache[anahtar];
    if (kayit != null && simdi.difference(kayit.zaman) <= cacheSuresi) {
      return kayit.havaDurumu;
    }

    final Response<dynamic> yanit = await dio.get<dynamic>(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: <String, Object?>{
        'latitude': konum.latitude,
        'longitude': konum.longitude,
        'current_weather': true,
        'timezone': 'auto',
      },
      options: Options(responseType: ResponseType.json),
    );

    final Map<String, Object?> veri = yanit.data as Map<String, Object?>;
    final Map<String, Object?>? anlik =
        veri['current_weather'] as Map<String, Object?>?;
    if (anlik == null) {
      throw StateError('Open-Meteo servisinden geçerli hava verisi alınamadı');
    }

    final double sicaklik = (anlik['temperature']! as num).toDouble();
    final double? ruzgar = (anlik['windspeed'] as num?)?.toDouble();
    final String durumMetni = _havaKodunuCoz(anlik['weathercode'] as int?);
    final DateTime guncellemeZamani =
        DateTime.tryParse(anlik['time']?.toString() ?? '') ?? simdi;

    final HavaDurumu sonuc = HavaDurumu(
      sicaklikC: sicaklik,
      hissedilenSicaklikC: null,
      ruzgarHiziMs: ruzgar != null ? ruzgar / 3.6 : null,
      havaDurumuMetni: durumMetni,
      guncellemeZamani: guncellemeZamani,
    );
    _cache[anahtar] = _CacheKaydi(havaDurumu: sonuc, zaman: simdi);
    return sonuc;
  }

  String _anahtarUret(LatLng konum) {
    final double lat = _yuvet(konum.latitude);
    final double lon = _yuvet(konum.longitude);
    return '$lat,$lon';
  }

  double _yuvet(double deger) {
    return (deger * 1000).roundToDouble() / 1000.0;
  }

  String _havaKodunuCoz(int? kod) {
    if (kod == null) {
      return 'Bilinmiyor';
    }
    switch (kod) {
      case 0:
        return 'Açık';
      case 1:
      case 2:
      case 3:
        return 'Parçalı bulutlu';
      case 45:
      case 48:
        return 'Sisli';
      case 51:
      case 53:
      case 55:
        return 'Çiseleme';
      case 61:
      case 63:
      case 65:
        return 'Yağmur';
      case 71:
      case 73:
      case 75:
        return 'Kar';
      case 95:
      case 96:
      case 99:
        return 'Fırtına';
      default:
        return 'Hava durumu kodu: $kod';
    }
  }
}

class _CacheKaydi {
  final HavaDurumu havaDurumu;
  final DateTime zaman;

  _CacheKaydi({required this.havaDurumu, required this.zaman});
}

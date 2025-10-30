import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

class GeojsonParselKayit {
  final String arsaNo;
  final String adaNo;
  final String parselNo;
  final List<LatLng> sinirNoktalari;
  const GeojsonParselKayit({
    required this.arsaNo,
    required this.adaNo,
    required this.parselNo,
    required this.sinirNoktalari,
  });
}

class GeojsonParselKaynagi {
  final String assetYolu;
  Map<String, GeojsonParselKayit>? _indeks;
  GeojsonParselKaynagi({required this.assetYolu});

  Future<void> yukleVeIndeksOlustur() async {
    if (_indeks != null) {
      return;
    }
    final String jsonIcerik = await rootBundle.loadString(assetYolu);
    final Map<String, Object?> kok = json.decode(jsonIcerik) as Map<String, Object?>;
    final List<Object?> hamOzellikler = (kok['features'] as List<Object?>?) ?? <Object?>[];
    final Map<String, GeojsonParselKayit> yeniIndeks = <String, GeojsonParselKayit>{};
    for (final Object? o in hamOzellikler) {
      if (o is! Map<String, Object?>) continue;
      final Map<String, Object?> ozellik = o;
      final Map<String, Object?> ozellikler =
          (ozellik['properties'] as Map<String, Object?>?) ?? <String, Object?>{};
      final String? arsaNo = ozellikler['arsaNo']?.toString();
      final String? adaNo = ozellikler['adaNo']?.toString();
      final String? parselNo = ozellikler['parselNo']?.toString();
      if (arsaNo == null || adaNo == null || parselNo == null) continue;

      final Map<String, Object?> geometri =
          (ozellik['geometry'] as Map<String, Object?>?) ?? <String, Object?>{};
      final String? tur = geometri['type']?.toString();
      if (tur != 'Polygon') continue;
      final List<Object?> koordinatlarKok =
          (geometri['coordinates'] as List<Object?>?) ?? <Object?>[];
      if (koordinatlarKok.isEmpty) continue;
      final List<Object?> halka = (koordinatlarKok.first as List<Object?>?) ?? <Object?>[];
      final List<LatLng> noktalar = <LatLng>[];
      for (final Object? p in halka) {
        if (p is! List<Object?>) continue;
        if (p.length < 2) continue;
        final double? x = _toDouble(p[0]);
        final double? y = _toDouble(p[1]);
        if (x == null || y == null) continue;
        // GeoJSON: [lon, lat]
        noktalar.add(LatLng(y, x));
      }
      if (noktalar.length < 3) continue;
      final GeojsonParselKayit kayit = GeojsonParselKayit(
        arsaNo: arsaNo,
        adaNo: adaNo,
        parselNo: parselNo,
        sinirNoktalari: noktalar,
      );
      yeniIndeks[_anahtar(arsaNo: arsaNo, adaNo: adaNo, parselNo: parselNo)] = kayit;
    }
    _indeks = yeniIndeks;
  }

  Future<GeojsonParselKayit?> bul({
    required String arsaNo,
    required String adaNo,
    required String parselNo,
  }) async {
    await yukleVeIndeksOlustur();
    final Map<String, GeojsonParselKayit>? indeks = _indeks;
    if (indeks == null) return null;
    return indeks[_anahtar(arsaNo: arsaNo, adaNo: adaNo, parselNo: parselNo)];
  }

  String _anahtar({required String arsaNo, required String adaNo, required String parselNo}) {
    return '${arsaNo.trim()}|${adaNo.trim()}|${parselNo.trim()}';
  }

  double? _toDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final String s = v.toString();
    return double.tryParse(s);
  }
}

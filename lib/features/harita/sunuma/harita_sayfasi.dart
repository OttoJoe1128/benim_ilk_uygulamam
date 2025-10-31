import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:benim_ilk_uygulamam/core/sabitler/harita_sabitleri.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/harita_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/harita_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/konum_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/konum_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sensor_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sensor_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sulama_cizim_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sulama_cizim_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/tasarim_modu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/tasarim_modu_provider.dart';
import 'package:benim_ilk_uygulamam/features/harita/sunuma/ciftlik_tasarim_paneli.dart';
import 'package:benim_ilk_uygulamam/features/harita/varliklar/sensor.dart';

@RoutePage(name: 'HaritaRoute')
class HaritaEkraniKapsayici extends StatelessWidget {
  const HaritaEkraniKapsayici({super.key});

  @override
  Widget build(BuildContext context) {
    return const HaritaSayfasi();
  }
}

class HaritaSayfasi extends ConsumerStatefulWidget {
  const HaritaSayfasi({super.key});

  @override
  ConsumerState<HaritaSayfasi> createState() => _HaritaSayfasiState();
}

class _HaritaSayfasiState extends ConsumerState<HaritaSayfasi> {
  final TextEditingController arsaDenetleyici = TextEditingController();
  final TextEditingController adaDenetleyici = TextEditingController();
  final TextEditingController parselDenetleyici = TextEditingController();
  final MapController haritaDenetleyici = MapController();
  ProviderSubscription<KonumDurumu>? konumAboneligi;
  ProviderSubscription<SensorDurumu>? sensorAboneligi;

  @override
  void initState() {
    super.initState();
    konumAboneligi = ref.listenManual<KonumDurumu>(konumDenetleyiciProvider, (
      KonumDurumu? onceki,
      KonumDurumu yeni,
    ) {
      if (!mounted) {
        return;
      }
      if (yeni is KonumHataDurumu || yeni is KonumIzinRedDurumu) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final String mesaj = yeni is KonumHataDurumu
              ? yeni.mesaj
              : (yeni as KonumIzinRedDurumu).mesaj;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mesaj)));
        });
      }
      if (yeni is KonumBasariliDurumu) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          haritaDenetleyici.move(
            yeni.kullaniciKonumu,
            HaritaSabitleri.VARSAYILAN_YAKINLASMA,
          );
        });
      }
    });
    sensorAboneligi = ref.listenManual<SensorDurumu>(
      sensorDenetleyiciProvider,
      (SensorDurumu? onceki, SensorDurumu yeni) {
        if (!mounted) {
          return;
        }
        final String? mesaj = yeni.hataMesaji;
        final bool mesajDegisti =
            mesaj != null && mesaj.isNotEmpty && mesaj != onceki?.hataMesaji;
        if (mesajDegisti) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mesaj)));
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(ref.read(sensorDenetleyiciProvider.notifier).yukleSensorler());
      unawaited(
        ref.read(sulamaCizimDenetleyiciProvider.notifier).yukleNoktalar(),
      );
    });
  }

  @override
  void dispose() {
    arsaDenetleyici.dispose();
    adaDenetleyici.dispose();
    parselDenetleyici.dispose();
    konumAboneligi?.close();
    sensorAboneligi?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HaritaDurumu durum = ref.watch(haritaDenetleyiciProvider);
    final KonumDurumu konumDurumu = ref.watch(konumDenetleyiciProvider);
    final TasarimModu tasarimModu = ref.watch(tasarimModuProvider);
    final SulamaCizimDurumu sulamaDurumu = ref.watch(
      sulamaCizimDenetleyiciProvider,
    );
    final SensorDurumu sensorDurumu = ref.watch(sensorDenetleyiciProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (durum is BasariliDurumu) {
        final LatLng merkez = durum.seciliParsel.hesaplaMerkez();
        haritaDenetleyici.move(merkez, HaritaSabitleri.VARSAYILAN_YAKINLASMA);
      }
    });

    final String tokenUyarisi = HaritaSabitleri.tokenUyarisi();

    final bool konumIslemde =
        konumDurumu is KonumYukleniyorDurumu ||
        konumDurumu is KonumIzinBekleniyorDurumu;
    final LatLng? kullaniciKonumu = konumDurumu is KonumBasariliDurumu
        ? konumDurumu.kullaniciKonumu
        : null;
    final bool sulamaCizimiVar = sulamaDurumu.noktalar.length >= 2;
    final List<Sensor> sensorler = sensorDurumu.sensorler;
    final bool tasarimIsaretcisiGoster = tasarimModu != TasarimModu.hicbiri;
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Agro – Harita')),
      body: Column(
        children: <Widget>[
          if (tokenUyarisi.isNotEmpty)
            MaterialBanner(
              content: Text(tokenUyarisi),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                  child: const Text('Kapat'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: arsaDenetleyici,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Arsa No'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: adaDenetleyici,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ada No'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: parselDenetleyici,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Parsel No'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(haritaDenetleyiciProvider.notifier)
                        .araVeSec(
                          arsaNo: arsaDenetleyici.text.trim(),
                          adaNo: adaDenetleyici.text.trim(),
                          parselNo: parselDenetleyici.text.trim(),
                        );
                  },
                  child: const Text('Bul'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                FlutterMap(
                  mapController: haritaDenetleyici,
                  options: MapOptions(
                    initialCenter: const LatLng(
                      HaritaSabitleri.BASLANGIC_ENLEM,
                      HaritaSabitleri.BASLANGIC_BOYLAM,
                    ),
                    initialZoom: HaritaSabitleri.VARSAYILAN_YAKINLASMA,
                    onTap: (TapPosition _, LatLng nokta) {
                      unawaited(_isleHaritaTiklama(nokta: nokta));
                    },
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate: HaritaSabitleri.tileUrlSablonu(),
                      userAgentPackageName: 'benim_ilk_uygulamam',
                    ),
                    if (durum is BasariliDurumu)
                      PolygonLayer(
                        polygons: <Polygon>[
                          Polygon(
                            borderColor: Colors.green.shade700,
                            borderStrokeWidth: 2.0,
                            color: Colors.green.withValues(alpha: 0.25),
                            points: durum.seciliParsel.sinirNoktalari,
                          ),
                        ],
                      ),
                    if (kullaniciKonumu != null)
                      CircleLayer(
                        circles: <CircleMarker>[
                          CircleMarker(
                            point: kullaniciKonumu,
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderColor: Colors.blueAccent,
                            borderStrokeWidth: 2,
                            useRadiusInMeter: true,
                            radius: 35,
                          ),
                        ],
                      ),
                    if (kullaniciKonumu != null)
                      MarkerLayer(
                        markers: <Marker>[
                          Marker(
                            point: kullaniciKonumu,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    if (sulamaCizimiVar)
                      PolylineLayer(
                        polylines: <Polyline>[
                          Polyline(
                            points: sulamaDurumu.noktalar,
                            strokeWidth: 4,
                            color: Colors.teal.shade600,
                          ),
                        ],
                      ),
                    if (sensorler.isNotEmpty)
                      MarkerLayer(
                        markers: sensorler
                            .map(
                              (Sensor sensor) => Marker(
                                point: sensor.konum,
                                width: 48,
                                height: 48,
                                child: Tooltip(
                                  message: sensor.ad,
                                  child: const Icon(
                                    Icons.sensors,
                                    color: Colors.deepOrange,
                                    size: 28,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
                if (tasarimIsaretcisiGoster)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Chip(
                      avatar: Icon(
                        tasarimModu == TasarimModu.sulamaCizimi
                            ? Icons.timeline
                            : Icons.sensors,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        tasarimModu == TasarimModu.sulamaCizimi
                            ? 'Sulama çizimi aktif (${sulamaDurumu.noktalar.length})'
                            : 'Sensör ekleme modu',
                      ),
                      backgroundColor: Colors.teal.shade600,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: konumIslemde
                        ? null
                        : () async {
                            await ref
                                .read(konumDenetleyiciProvider.notifier)
                                .isteKonumVeIzinleri();
                          },
                    tooltip: 'Konumuma git',
                    child: konumIslemde
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          if (durum is YukleniyorDurumu ||
              konumIslemde ||
              sensorDurumu.isYukleniyor)
            const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }

  void _gosterTasarimPaneli(BuildContext context, BasariliDurumu durum) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        final String baslik =
            'Arsa ${durum.seciliParsel.arsaNo} · Ada ${durum.seciliParsel.adaNo} · Parsel ${durum.seciliParsel.parselNo}';
        return CiftlikTasarimPaneli(baslik: baslik);
      },
    );
  }

  Future<void> _isleHaritaTiklama({required LatLng nokta}) async {
    final TasarimModu aktifMod = ref.read(tasarimModuProvider);
    if (aktifMod == TasarimModu.sulamaCizimi) {
      ref.read(sulamaCizimDenetleyiciProvider.notifier).ekleNokta(nokta: nokta);
      return;
    }
    if (aktifMod == TasarimModu.sensorEkle) {
      await _gosterSensorEklemeFormu(konum: nokta);
      return;
    }
    final HaritaDurumu mevcutDurum = ref.read(haritaDenetleyiciProvider);
    if (mevcutDurum is BasariliDurumu) {
      final HaritaDenetleyici denetleyici = ref.read(
        haritaDenetleyiciProvider.notifier,
      );
      final bool icinde = denetleyici.isNoktaPoligonIcinde(
        nokta: nokta,
        poligon: mevcutDurum.seciliParsel.sinirNoktalari,
      );
      if (icinde) {
        _gosterTasarimPaneli(context, mevcutDurum);
      }
    }
  }

  Future<void> _gosterSensorEklemeFormu({required LatLng konum}) async {
    final TextEditingController adDenetleyici = TextEditingController();
    try {
      final bool? sonuc = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Sensör Ekle'),
            content: TextField(
              controller: adDenetleyici,
              decoration: const InputDecoration(labelText: 'Sensör Adı'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Ekle'),
              ),
            ],
          );
        },
      );
      if (sonuc != true) {
        return;
      }
      await ref
          .read(sensorDenetleyiciProvider.notifier)
          .ekleSensor(ad: adDenetleyici.text, konum: konum);
      final SensorDurumu guncelDurum = ref.read(sensorDenetleyiciProvider);
      if (guncelDurum.hataMesaji == null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sensör eklendi')));
      }
    } finally {
      adDenetleyici.dispose();
    }
  }
}

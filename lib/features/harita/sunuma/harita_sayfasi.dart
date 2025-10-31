import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:benim_ilk_uygulamam/core/sabitler/harita_sabitleri.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/harita_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/harita_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/sunuma/ciftlik_tasarim_paneli.dart';

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

  @override
  void dispose() {
    arsaDenetleyici.dispose();
    adaDenetleyici.dispose();
    parselDenetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HaritaDurumu durum = ref.watch(haritaDenetleyiciProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (durum is BasariliDurumu) {
        final LatLng merkez = durum.seciliParsel.hesaplaMerkez();
        haritaDenetleyici.move(merkez, HaritaSabitleri.VARSAYILAN_YAKINLASMA);
      }
    });

    final String tokenUyarisi = HaritaSabitleri.tokenUyarisi();

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Agro – Harita')),
      body: Column(
        children: <Widget>[
          if (tokenUyarisi.isNotEmpty)
            MaterialBanner(
              content: Text(tokenUyarisi),
              actions: <Widget>[
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                  child: const Text('Kapat'),
                )
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                    await ref.read(haritaDenetleyiciProvider.notifier).araVeSec(
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
            child: FlutterMap(
              mapController: haritaDenetleyici,
              options: MapOptions(
                initialCenter: const LatLng(
                  HaritaSabitleri.BASLANGIC_ENLEM,
                  HaritaSabitleri.BASLANGIC_BOYLAM,
                ),
                initialZoom: HaritaSabitleri.VARSAYILAN_YAKINLASMA,
                onTap: (TapPosition _, LatLng nokta) {
                  final HaritaDenetleyici not = ref.read(haritaDenetleyiciProvider.notifier);
                  if (durum is BasariliDurumu) {
                    final bool icinde = not.isNoktaPoligonIcinde(
                      nokta: nokta,
                      poligon: durum.seciliParsel.sinirNoktalari,
                    );
                    if (icinde) {
                      _gosterTasarimPaneli(context, durum);
                    }
                  }
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
                        color: Colors.green.withOpacity(0.25),
                        points: durum.seciliParsel.sinirNoktalari,
                        isFilled: true,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (durum is YukleniyorDurumu)
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
        final String baslik = 'Arsa ${durum.seciliParsel.arsaNo} · Ada ${durum.seciliParsel.adaNo} · Parsel ${durum.seciliParsel.parselNo}';
        return CiftlikTasarimPaneli(baslik: baslik);
      },
    );
  }
}

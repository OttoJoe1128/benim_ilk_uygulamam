import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:benim_ilk_uygulamam/core/sabitler/harita_sabitleri.dart';
import 'package:benim_ilk_uygulamam/core/ui/adaptif_tema_yoneticisi.dart';
import 'package:benim_ilk_uygulamam/features/ai/ai_saglayicilar.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/nova_ai_karari.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/sensor_olcumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/harita_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/depocular/geojson_parsel_konum_deposu.dart';
import 'package:benim_ilk_uygulamam/features/harita/modeller/open_meteo_verisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/veri_kaynaklari/geojson_parsel_kaynagi.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/harita_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/sunuma/ciftlik_tasarim_paneli.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_saglayicilar.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_senkron_servisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/veri_kaynaklari/open_meteo_saglayicisi.dart';
import 'package:benim_ilk_uygulamam/features/harita/veri_kaynaklari/open_meteo_servisi.dart';

class HaritaEkraniKapsayici extends StatelessWidget {
  const HaritaEkraniKapsayici({super.key});

  @override
  Widget build(BuildContext context) {
    final GeojsonParselKaynagi kaynagi = GeojsonParselKaynagi(
      assetYolu: 'assets/geo/parseller.geojson',
    );
    final GeojsonParselKonumDeposu depo = GeojsonParselKonumDeposu(kaynagi: kaynagi);
    return ProviderScope(
      overrides: <Override>[
        haritaDenetleyiciProvider.overrideWith((Ref ref) => HaritaDenetleyici(parselKonumDeposu: depo)),
      ],
      child: const HaritaSayfasi(),
    );
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
  Timer? adaptifZamanlayici;
  int birikmisTiklamaSayisi = 0;
  String? sonParselAnahtari;
  OpenMeteoVerisi? sonOpenMeteoVerisi;

  @override
  void initState() {
    super.initState();
    adaptifZamanlayici = Timer.periodic(const Duration(seconds: 30), (Timer _) {
      ref.read(adaptifUiProvider.notifier).guncelleKullanim(sureArtisi: const Duration(seconds: 30), tiklamaArtisi: birikmisTiklamaSayisi);
      birikmisTiklamaSayisi = 0;
    });
  }

  @override
  void dispose() {
    arsaDenetleyici.dispose();
    adaDenetleyici.dispose();
    parselDenetleyici.dispose();
    adaptifZamanlayici?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HaritaDurumu durum = ref.watch(haritaDenetleyiciProvider);
    final AdaptifUiDurumu adaptifDurumu = ref.watch(adaptifUiProvider);
    final MqttBaglantiDurumu mqttDurumu = ref.watch(mqttBaglantiDurumuProvider);
    final AsyncValue<NovaAiKarari?> aiKarar = ref.watch(novaAiSonKararProvider);
    final AsyncValue<SensorOlcumu?> sensorOlcum = ref.watch(sensorSonOlcumProvider);
    final MqttSenkronServisi mqttServisi = ref.watch(mqttSenkronServisiProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (durum is BasariliDurumu) {
        final LatLng merkez = durum.seciliParsel.hesaplaMerkez();
        haritaDenetleyici.move(merkez, HaritaSabitleri.VARSAYILAN_YAKINLASMA);
      }
    });

    if (durum is BasariliDurumu) {
      _guncelleHavaAnalizi(durum: durum);
    }

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
          if (adaptifDurumu.aktifKartKimlikleri.contains('senkron'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: _buildMqttDurumCubugu(context: context, durum: mqttDurumu, servis: mqttServisi),
            ),
          if (adaptifDurumu.aktifKartKimlikleri.contains('ai'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: _buildAiKararKart(context: context, karar: aiKarar),
            ),
          if (adaptifDurumu.aktifKartKimlikleri.contains('sensor'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: _buildSensorKart(context: context, olcum: sensorOlcum),
            ),
          if (adaptifDurumu.aktifKartKimlikleri.contains('hava') && sonOpenMeteoVerisi != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: _buildHavaKart(context: context, veri: sonOpenMeteoVerisi!),
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
                    _arttirTiklamaSayaci();
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
                  _arttirTiklamaSayaci();
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

  void _arttirTiklamaSayaci() {
    birikmisTiklamaSayisi = birikmisTiklamaSayisi + 1;
  }

  Widget _buildMqttDurumCubugu({required BuildContext context, required MqttBaglantiDurumu durum, required MqttSenkronServisi servis}) {
    final ThemeData tema = Theme.of(context);
    final bool bagli = durum.asama == MqttBaglantiAsamasi.baglandi;
    final bool hata = durum.asama == MqttBaglantiAsamasi.hatali;
    final Color arkaPlan = bagli ? Colors.green.shade50 : hata ? Colors.red.shade50 : Colors.orange.shade50;
    final Color ikonRenk = bagli ? Colors.green.shade700 : hata ? Colors.red.shade700 : Colors.orange.shade700;
    final IconData ikon = bagli ? Icons.cloud_done : hata ? Icons.cloud_off : Icons.cloud_sync;
    final TextStyle yaziStili = tema.textTheme.bodyMedium ?? const TextStyle();
    final Stream<String> akim = servis.dinleGelenMesajlar();
    return Material(
      color: arkaPlan,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Icon(ikon, color: ikonRenk),
            const SizedBox(width: 12),
            Expanded(child: Text(durum.mesaj, style: yaziStili)),
            StreamBuilder<String>(
              stream: akim,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                final String icerik = snapshot.data ?? '';
                if (icerik.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Text(icerik, style: yaziStili.copyWith(color: ikonRenk), maxLines: 1, overflow: TextOverflow.ellipsis);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiKararKart({required BuildContext context, required AsyncValue<NovaAiKarari?> karar}) {
    return karar.when(
      data: (NovaAiKarari? veri) {
        if (veri == null) {
          return _olusturBosKart(context: context, mesaj: 'AI verisi bekleniyor');
        }
        final ThemeData tema = Theme.of(context);
        final TextStyle baslikStili = tema.textTheme.titleMedium ?? const TextStyle(fontWeight: FontWeight.w600);
        final TextStyle yaziStili = tema.textTheme.bodyMedium ?? const TextStyle();
        final List<Widget> etiketler = veri.etiketler.map((String etiket) => Chip(label: Text(etiket))).toList();
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nova AI Önerisi', style: baslikStili),
                const SizedBox(height: 8),
                Text(veri.mesaj, style: yaziStili),
                if (etiketler.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(spacing: 6, runSpacing: 6, children: etiketler),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (Object hata, StackTrace _) => _olusturBosKart(context: context, mesaj: 'AI hatası: ${hata.toString()}'),
    );
  }

  Widget _buildSensorKart({required BuildContext context, required AsyncValue<SensorOlcumu?> olcum}) {
    return olcum.when(
      data: (SensorOlcumu? veri) {
        if (veri == null) {
          return _olusturBosKart(context: context, mesaj: 'Sensör verisi bulunamadı');
        }
        final ThemeData tema = Theme.of(context);
        final TextStyle yaziStili = tema.textTheme.bodyMedium ?? const TextStyle();
        final String saat = '${veri.olcumZamani.hour.toString().padLeft(2, '0')}:${veri.olcumZamani.minute.toString().padLeft(2, '0')}';
        final List<Widget> etiketler = <Widget>[
          Chip(label: Text('Toprak Nemi: %${veri.toprakNemiYuzde.toStringAsFixed(1)}')),
          Chip(label: Text('Toprak Isısı: ${veri.toprakSicakligiSantigrat.toStringAsFixed(1)}°C')),
          Chip(label: Text('Hava Isısı: ${veri.havaSicakligiSantigrat.toStringAsFixed(1)}°C')),
          Chip(label: Text('Işık: ${veri.isikSeviyesiLuks.toStringAsFixed(0)} Lüks')),
          Chip(label: Text('Bağıl Nem: %${veri.bagilNemYuzde.toStringAsFixed(0)}')),
        ];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Sensör Sonuçları ($saat)', style: tema.textTheme.titleMedium ?? const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: etiketler),
                const SizedBox(height: 6),
                Text('Kaynak: ${veri.kaynak}', style: yaziStili),
              ],
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (Object hata, StackTrace _) => _olusturBosKart(context: context, mesaj: 'Sensör hatası: ${hata.toString()}'),
    );
  }

  Widget _buildHavaKart({required BuildContext context, required OpenMeteoVerisi veri}) {
    final ThemeData tema = Theme.of(context);
    final TextStyle yaziStili = tema.textTheme.bodyMedium ?? const TextStyle();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Open-Meteo Tahmini', style: tema.textTheme.titleMedium ?? const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Hava: ${veri.havaSicakligiSantigrat.toStringAsFixed(1)}°C · Bağıl Nem: %${veri.bagilNemYuzde.toStringAsFixed(0)}', style: yaziStili),
            Text('Toprak: ${veri.toprakSicakligiSantigrat.toStringAsFixed(1)}°C · Nem: %${veri.toprakNemiOran.toStringAsFixed(1)}', style: yaziStili),
            Text('Işık: ${veri.isikSeviyesiLuks.toStringAsFixed(0)} Lüks', style: yaziStili),
            Text('Zaman: ${veri.olcumZamani.toLocal()}', style: yaziStili),
          ],
        ),
      ),
    );
  }

  Widget _olusturBosKart({required BuildContext context, required String mesaj}) {
    final ThemeData tema = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(mesaj, style: tema.textTheme.bodyMedium ?? const TextStyle()),
      ),
    );
  }

  void _guncelleHavaAnalizi({required BasariliDurumu durum}) {
    final String anahtar = '${durum.seciliParsel.arsaNo}-${durum.seciliParsel.adaNo}-${durum.seciliParsel.parselNo}';
    if (sonParselAnahtari == anahtar) {
      return;
    }
    sonParselAnahtari = anahtar;
    final OpenMeteoServisi servis = ref.read(openMeteoServisiProvider);
    final LatLng merkez = durum.seciliParsel.hesaplaMerkez();
    Future<void>.microtask(() async {
      try {
        final OpenMeteoAnalizSonucu sonuc = await servis.getirVeriVeAnalizEt(enlem: merkez.latitude, boylam: merkez.longitude);
        if (!mounted) {
          return;
        }
        setState(() {
          sonOpenMeteoVerisi = sonuc.veri;
        });
        ref.invalidate(novaAiSonKararProvider);
        ref.invalidate(sensorSonOlcumProvider);
      } catch (Object hata) {
        debugPrint('OpenMeteo hatası: $hata');
        sonParselAnahtari = null;
      }
    });
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

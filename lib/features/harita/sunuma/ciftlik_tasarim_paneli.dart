import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sensor_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sensor_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sulama_cizim_denetleyici.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sulama_cizim_durumu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/tasarim_modu.dart';
import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/tasarim_modu_provider.dart';
import 'package:benim_ilk_uygulamam/features/harita/varliklar/sensor.dart';

class CiftlikTasarimPaneli extends ConsumerWidget {
  final String baslik;
  const CiftlikTasarimPaneli({super.key, required this.baslik});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TasarimModu tasarimModu = ref.watch(tasarimModuProvider);
    final SulamaCizimDurumu sulamaDurumu = ref.watch(
      sulamaCizimDenetleyiciProvider,
    );
    final SensorDurumu sensorDurumu = ref.watch(sensorDenetleyiciProvider);
    final bool cizimAktif =
        tasarimModu == TasarimModu.sulamaCizimi && sulamaDurumu.isCizimAcik;
    final bool sensorModuAktif = tasarimModu == TasarimModu.sensorEkle;
    final bool geriAlAktif = sulamaDurumu.noktalar.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(baslik, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton(
                  onPressed: () {
                    final TasarimModu hedefMod = cizimAktif
                        ? TasarimModu.hicbiri
                        : TasarimModu.sulamaCizimi;
                    ref.read(tasarimModuProvider.notifier).state = hedefMod;
                    ref
                        .read(sulamaCizimDenetleyiciProvider.notifier)
                        .baslatCizim();
                  },
                  child: Text(
                    cizimAktif ? 'Sulama Çizimini Bitir' : 'Sulama Hattı Çiz',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final TasarimModu hedefMod = sensorModuAktif
                        ? TasarimModu.hicbiri
                        : TasarimModu.sensorEkle;
                    if (hedefMod == TasarimModu.sensorEkle &&
                        sulamaDurumu.isCizimAcik) {
                      ref
                          .read(sulamaCizimDenetleyiciProvider.notifier)
                          .baslatCizim();
                    }
                    ref.read(tasarimModuProvider.notifier).state = hedefMod;
                  },
                  child: Text(
                    sensorModuAktif
                        ? 'Sensör Modunu Kapat'
                        : 'Sensör Noktası Ekle',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Çit/alan çizimi yakında eklenecek'),
                      ),
                    );
                  },
                  child: const Text('Çit/Alan Çiz'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tasarımlar geçici olarak bellekte tutuluyor',
                        ),
                      ),
                    );
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            ),
            if (cizimAktif)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: geriAlAktif
                          ? () {
                              ref
                                  .read(sulamaCizimDenetleyiciProvider.notifier)
                                  .geriAl();
                            }
                          : null,
                      child: const Text('Geri Al'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: geriAlAktif
                          ? () {
                              ref
                                  .read(sulamaCizimDenetleyiciProvider.notifier)
                                  .temizle();
                            }
                          : null,
                      child: const Text('Temizle'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text('Sensörler', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (sensorDurumu.sensorler.isEmpty)
              const Text(
                'Henüz sensör eklenmedi.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sensorDurumu.sensorler.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (BuildContext ctx, int index) {
                  final Sensor sensor = sensorDurumu.sensorler[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(sensor.ad),
                    subtitle: Text(
                      '${sensor.konum.latitude.toStringAsFixed(5)}, ${sensor.konum.longitude.toStringAsFixed(5)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            _gosterSensorDuzenlemeDialog(
                              context: context,
                              ref: ref,
                              sensor: sensor,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () {
                            _gosterSensorSilmeOnayi(
                              context: context,
                              ref: ref,
                              sensor: sensor,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _gosterSensorDuzenlemeDialog({
    required BuildContext context,
    required WidgetRef ref,
    required Sensor sensor,
  }) async {
    final TextEditingController adDenetleyici = TextEditingController(
      text: sensor.ad,
    );
    try {
      final bool? sonuc = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Sensörü Düzenle'),
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
                child: const Text('Güncelle'),
              ),
            ],
          );
        },
      );
      if (sonuc == true) {
        await ref
            .read(sensorDenetleyiciProvider.notifier)
            .guncelleSensor(sensorId: sensor.id, ad: adDenetleyici.text);
        if (!context.mounted) {
          return;
        }
        final SensorDurumu durum = ref.read(sensorDenetleyiciProvider);
        if (durum.hataMesaji == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sensör güncellendi')));
        }
      }
    } finally {
      adDenetleyici.dispose();
    }
  }

  Future<void> _gosterSensorSilmeOnayi({
    required BuildContext context,
    required WidgetRef ref,
    required Sensor sensor,
  }) async {
    final bool? onay = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Sensörü Sil'),
          content: Text(
            '${sensor.ad} sensörünü silmek istediğinize emin misiniz?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
    if (onay == true) {
      await ref
          .read(sensorDenetleyiciProvider.notifier)
          .silSensor(sensorId: sensor.id);
      if (!context.mounted) {
        return;
      }
      final SensorDurumu durum = ref.read(sensorDenetleyiciProvider);
      if (durum.hataMesaji == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sensör silindi')));
      }
    }
  }
}

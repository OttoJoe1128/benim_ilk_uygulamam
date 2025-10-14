import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/varliklar/pano.dart';
import '../denetleyiciler/pano_denetleyici.dart';
import '../../../../core/di/servis_bulucu.dart';
import '../../../domain/sozlesmeler/pano_deposu.dart';
import '../durum/pano_durumu.dart';

@RoutePage()
class PanoListesiSayfasi extends ConsumerStatefulWidget {
  const PanoListesiSayfasi({super.key});
  @override
  ConsumerState<PanoListesiSayfasi> createState() => _PanoListesiSayfasiState();
}

class _PanoListesiSayfasiState extends ConsumerState<PanoListesiSayfasi> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(panoDenetleyiciProvider.notifier).getirPanolari());
  }

  @override
  Widget build(BuildContext context) {
    final PanoDurumu durum = ref.watch(panoDenetleyiciProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Panolar')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.router.pushNamed('/olustur');
          if (!mounted) return;
          await ref.read(panoDenetleyiciProvider.notifier).getirPanolari();
        },
        child: const Icon(Icons.add),
      ),
      body: switch (durum) {
        _Yukleniyor() => const Center(child: CircularProgressIndicator()),
        _Basarisiz(:final String mesaj) => Center(child: Text(mesaj)),
        _Basarili(:final List<Pano> panolar) => ListView.builder(
            itemCount: panolar.length,
            itemBuilder: (BuildContext context, int index) {
              final Pano p = panolar[index];
              return ListTile(
                title: Text(p.baslik),
                subtitle: Text('Bitiş: ${p.bitis}'),
                onTap: () => context.router.pushNamed('/pano/${p.id}'),
              );
            },
          ),
      },
    );
  }
}

final AutoDisposeStateNotifierProvider<PanoDenetleyici, PanoDurumu> panoDenetleyiciProvider =
    StateNotifierProvider.autoDispose<PanoDenetleyici, PanoDurumu>((AutoDisposeStateNotifierProviderRef<PanoDurumu> ref) {
  final PanoDeposu depo = servisBulucu.get<PanoDeposu>();
  return PanoDenetleyici(panoDeposu: depo);
});

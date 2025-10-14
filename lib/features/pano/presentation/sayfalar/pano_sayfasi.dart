import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/servis_bulucu.dart';
import '../../../sohbet/domain/sozlesmeler/sohbet_deposu.dart';
import '../../../sohbet/domain/varliklar/mesaj.dart';
import '../../../sohbet/presentation/denetleyiciler/sohbet_denetleyici.dart';
import '../../../sohbet/presentation/durum/sohbet_durumu.dart';

@RoutePage()
class PanoSayfasi extends ConsumerStatefulWidget {
  const PanoSayfasi({super.key});
  @override
  ConsumerState<PanoSayfasi> createState() => _PanoSayfasiState();
}

class _PanoSayfasiState extends ConsumerState<PanoSayfasi> {
  late final String panoId;
  final TextEditingController mesajKontrol = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    panoId = RouteData.of(context).pathParams.getString('id');
    Future<void>.microtask(() => ref.read(_providerFor(panoId).notifier).getirMesajlari());
  }

  @override
  void dispose() {
    mesajKontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SohbetDurumu durum = ref.watch(_providerFor(panoId));
    return Scaffold(
      appBar: AppBar(title: const Text('Pano')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: switch (durum) {
              _Yukleniyor() => const Center(child: CircularProgressIndicator()),
              _Basarisiz(:final String mesaj) => Center(child: Text(mesaj)),
              _Basarili(:final List<Mesaj> mesajlar) => ListView.separated(
                  reverse: true,
                  itemCount: mesajlar.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final Mesaj m = mesajlar[mesajlar.length - 1 - index];
                    return ListTile(
                      title: Text(m.icerik),
                      subtitle: Text(m.zaman.toIso8601String()),
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                    );
                  },
                ),
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: mesajKontrol,
                      decoration:
                          const InputDecoration(hintText: 'Mesaj yaz...', prefixIcon: Icon(Icons.message_outlined)),
                      onSubmitted: (_) async {
                        final String yazi = mesajKontrol.text.trim();
                        if (yazi.isEmpty) return;
                        await ref.read(_providerFor(panoId).notifier).gonderMesaj(yazi);
                        mesajKontrol.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Gönder'),
                    onPressed: () async {
                      final String yazi = mesajKontrol.text.trim();
                      if (yazi.isEmpty) return;
                      await ref.read(_providerFor(panoId).notifier).gonderMesaj(yazi);
                      mesajKontrol.clear();
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

AutoDisposeStateNotifierProvider<SohbetDenetleyici, SohbetDurumu> _providerFor(String panoId) {
  return StateNotifierProvider.autoDispose<SohbetDenetleyici, SohbetDurumu>((AutoDisposeStateNotifierProviderRef<SohbetDurumu> ref) {
    final SohbetDeposu depo = servisBulucu.get<SohbetDeposu>();
    return SohbetDenetleyici(sohbetDeposu: depo, panoId: panoId);
  });
}

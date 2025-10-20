import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/sabitler/uygulama_sabitleri.dart';
import '../denetleyiciler/tani_denetleyicisi.dart';
import '../durumlar/tani_durumu.dart';

class AnaSayfa extends ConsumerWidget {
  const AnaSayfa({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TaniDurumu durum = ref.watch(taniDenetleyicisiProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bitki Analiz Sistemi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => ref.read(taniDenetleyicisiProvider.notifier).baslatTani(goruntuYolu: 'ornek.jpg'),
                child: const Text('Örnek Görüntü ile Tanı Yap'),
              ),
              const SizedBox(height: 16),
              _DurumGoruntule(durum: durum),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(UygulamaSabitleri.rotaCekim),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class _DurumGoruntule extends StatelessWidget {
  final TaniDurumu durum;
  const _DurumGoruntule({required this.durum});
  @override
  Widget build(BuildContext context) {
    return switch (durum) {
      Baslangic() => const Text('Başlamak için görsel seçin veya çekin.'),
      Yukleniyor() => const CircularProgressIndicator(),
      Basari(:final etiketler) => Column(
          children: etiketler.map((e) => Text(e)).toList(growable: false),
        ),
      Hata(:final mesaj) => Text('Hata: $mesaj'),
    };
  }
}

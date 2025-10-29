// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kimlik_controller.dart';

class KimlikSayfasi extends ConsumerStatefulWidget {
  final Widget hedef;
  const KimlikSayfasi({super.key, required this.hedef});
  @override
  ConsumerState<KimlikSayfasi> createState() => _KimlikSayfasiDurumu();
}

class _KimlikSayfasiDurumu extends ConsumerState<KimlikSayfasi> {
  final TextEditingController anahtarDenetleyicisi = TextEditingController();
  @override
  void dispose() {
    anahtarDenetleyicisi.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final KimlikDurumu durum = ref.watch(kimlikSaglayici);
    if (durum.girisYaptiMi) return widget.hedef;
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: <Widget>[
          const Text('Özel anahtarınızı girin (test ağı)'),
          const SizedBox(height: 12),
          TextField(controller: anahtarDenetleyicisi, decoration: const InputDecoration(hintText: '0x...'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.read(kimlikSaglayici.notifier).girisYap(ozelAnahtar: anahtarDenetleyicisi.text);
            },
            child: const Text('Giriş Yap'),
          ),
          if (durum.hata.isNotEmpty) Text(durum.hata, style: const TextStyle(color: Colors.red)),
        ]),
      ),
    );
  }
}

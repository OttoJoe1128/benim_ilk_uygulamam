// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/github_repository_entity.dart';
import '../controllers/search_controller.dart';

class AramaSayfasi extends ConsumerStatefulWidget {
  const AramaSayfasi({super.key});
  @override
  ConsumerState<AramaSayfasi> createState() => _AramaSayfasiDurumu();
}

class _AramaSayfasiDurumu extends ConsumerState<AramaSayfasi> {
  final TextEditingController aramaDenetleyicisi = TextEditingController();
  @override
  void dispose() {
    aramaDenetleyicisi.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final AramaDurumu durum = ref.watch(aramaSaglayici);
    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Gezgini')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                child: TextField(
                  controller: aramaDenetleyicisi,
                  decoration: const InputDecoration(hintText: 'Depo ara (örn: flutter)')
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  ref.read(aramaSaglayici.notifier).araDepoListesiniGuncelle(sorgu: aramaDenetleyicisi.text);
                },
                child: const Text('Ara'),
              )
            ]),
            const SizedBox(height: 12),
            if (durum.yukleniyorMu) const LinearProgressIndicator(),
            if (durum.hataMesaji.isNotEmpty) Text(durum.hataMesaji, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: ListView.separated(
                itemCount: durum.sonuclar.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int i) {
                  final GitHubDepoVarlik depo = durum.sonuclar[i];
                  return ListTile(
                    title: Text('${depo.sahip}/${depo.ad}'),
                    subtitle: Text(depo.aciklama, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.star, size: 16),
                        const SizedBox(width: 4),
                        Text('${depo.yildizSayisi}'),
                      ],
                    ),
                    onTap: () {
                      // Detay sayfasına yönlendirme burada yapılacak
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/bitki_analiz_sonucu.dart';
import '../controllers/bitki_controller.dart';

class BitkiAnalizSayfasi extends ConsumerStatefulWidget {
  const BitkiAnalizSayfasi({super.key});
  @override
  ConsumerState<BitkiAnalizSayfasi> createState() => _BitkiAnalizSayfasiDurumu();
}

class _BitkiAnalizSayfasiDurumu extends ConsumerState<BitkiAnalizSayfasi> {
  final ImagePicker secici = ImagePicker();
  XFile? secilen;
  @override
  Widget build(BuildContext context) {
    final BitkiDurumu durum = ref.watch(bitkiSaglayici);
    return Scaffold(
      appBar: AppBar(title: const Text('Bitki Analiz Sistemi')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  final XFile? x = await secici.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 90);
                  if (x != null) {
                    setState(() { secilen = x; });
                  }
                },
                child: const Text('Galeriden Seç'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final XFile? x = await secici.pickImage(source: ImageSource.camera, maxWidth: 1200, imageQuality: 90);
                  if (x != null) {
                    setState(() { secilen = x; });
                  }
                },
                child: const Text('Kameradan Çek'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: secilen == null ? null : () {
                  ref.read(bitkiSaglayici.notifier).analizEt(goruntuYolu: secilen!.path);
                },
                child: const Text('Analiz Et'),
              ),
            ]),
            const SizedBox(height: 12),
            if (secilen != null)
              SizedBox(height: 180, child: Image.file(File(secilen!.path))),
            if (durum.yukleniyorMu) const LinearProgressIndicator(),
            if (durum.hata.isNotEmpty) Text(durum.hata, style: const TextStyle(color: Colors.red)),
            if (durum.sonuc != null) _SonucKutusu(sonuc: durum.sonuc!),
          ],
        ),
      ),
    );
  }
}

class _SonucKutusu extends StatelessWidget {
  final BitkiAnalizSonucu sonuc;
  const _SonucKutusu({required this.sonuc});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Tür: ${sonuc.turAdi}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Güven Puanı: ${(sonuc.guvenPuani * 100).toStringAsFixed(1)}%'),
          const SizedBox(height: 8),
          if (sonuc.aciklama.isNotEmpty) Text(sonuc.aciklama),
          const SizedBox(height: 8),
          if (sonuc.etiketler.isNotEmpty) Wrap(spacing: 6, children: sonuc.etiketler.map((String e) => Chip(label: Text(e))).toList()),
        ]),
      ),
    );
  }
}

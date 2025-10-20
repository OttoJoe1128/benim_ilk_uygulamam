import 'package:flutter/material.dart';

class SonucSayfasi extends StatelessWidget {
  final List<String> etiketler;
  const SonucSayfasi({super.key, required this.etiketler});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sonuç')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, int i) => Text(etiketler[i]),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: etiketler.length,
      ),
    );
  }
}

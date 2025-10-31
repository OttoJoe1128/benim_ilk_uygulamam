import 'package:flutter/material.dart';

class CiftlikTasarimPaneli extends StatelessWidget {
  final String baslik;
  const CiftlikTasarimPaneli({super.key, required this.baslik});

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {},
                  child: const Text('Sulama Hattı Ekle'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Sensör Noktası Ekle'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Çit/Alan Çiz'),
                ),
                FilledButton(onPressed: () {}, child: const Text('Kaydet')),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

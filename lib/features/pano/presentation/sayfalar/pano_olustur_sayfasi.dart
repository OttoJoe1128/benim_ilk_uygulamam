import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/zaman_sabitleri.dart';

@RoutePage()
class PanoOlusturSayfasi extends StatefulWidget {
  const PanoOlusturSayfasi({super.key});
  @override
  State<PanoOlusturSayfasi> createState() => _PanoOlusturSayfasiState();
}

class _PanoOlusturSayfasiState extends State<PanoOlusturSayfasi> {
  final TextEditingController baslikKontrol = TextEditingController();
  SureSecenegi secenek = SureSecenegi.birSaat;

  @override
  void dispose() {
    baslikKontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pano Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: baslikKontrol,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            const SizedBox(height: 12),
            DropdownButton<SureSecenegi>(
              value: secenek,
              items: const <DropdownMenuItem<SureSecenegi>>[
                DropdownMenuItem(value: SureSecenegi.birSaat, child: Text('1 Saat')),
                DropdownMenuItem(value: SureSecenegi.birGun, child: Text('1 Gün')),
                DropdownMenuItem(value: SureSecenegi.birHafta, child: Text('1 Hafta')),
              ],
              onChanged: (SureSecenegi? v) {
                if (v == null) return;
                setState(() => secenek = v);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final Duration sure = donusturSureSecenegi(secenek);
                final DateTime bitis = DateTime.now().add(sure);
                // TODO: Denetleyici üzerinden oluştur ve geri dön
                Navigator.of(context).pop();
              },
              child: const Text('Oluştur'),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/zaman_sabitleri.dart';
import '../../presentation/denetleyiciler/pano_denetleyici.dart';
import '../../domain/sozlesmeler/pano_deposu.dart';
import '../../../../core/di/servis_bulucu.dart';

@RoutePage()
class PanoOlusturSayfasi extends ConsumerStatefulWidget {
  const PanoOlusturSayfasi({super.key});
  @override
  ConsumerState<PanoOlusturSayfasi> createState() => _PanoOlusturSayfasiState();
}

class _PanoOlusturSayfasiState extends ConsumerState<PanoOlusturSayfasi> {
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
              decoration: const InputDecoration(labelText: 'Başlık', prefixIcon: Icon(Icons.dashboard_outlined)),
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
              onPressed: () async {
                final String baslik = baslikKontrol.text.trim();
                if (baslik.isEmpty) return;
                final Duration sure = donusturSureSecenegi(secenek);
                final DateTime bitis = DateTime.now().add(sure);
                final PanoDenetleyici denetleyici =
                    PanoDenetleyici(panoDeposu: servisBulucu.get<PanoDeposu>());
                await denetleyici.olusturPano(baslik: baslik, bitis: bitis);
                if (!mounted) return;
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

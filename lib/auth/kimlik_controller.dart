// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kimlik_servisi.dart';

class KimlikDurumu {
  final bool girisYaptiMi;
  final String hata;
  const KimlikDurumu({required this.girisYaptiMi, required this.hata});
  KimlikDurumu kopyala({bool? girisYaptiMi, String? hata}) {
    return KimlikDurumu(girisYaptiMi: girisYaptiMi ?? this.girisYaptiMi, hata: hata ?? this.hata);
  }
}

class KimlikDenetleyici extends StateNotifier<KimlikDurumu> {
  final KimlikServisi servis;
  KimlikDenetleyici({required this.servis}) : super(const KimlikDurumu(girisYaptiMi: false, hata: ''));
  Future<void> durumuYukle() async {
    final bool varMi = await servis.isGirisYapildiMi();
    state = state.kopyala(girisYaptiMi: varMi);
  }
  Future<void> girisYap({required String ozelAnahtar}) async {
    if (ozelAnahtar.trim().isEmpty) {
      state = state.kopyala(hata: 'Geçersiz anahtar');
      return;
    }
    await servis.anahtarKaydet(ozelAnahtar: ozelAnahtar);
    state = state.kopyala(girisYaptiMi: true, hata: '');
  }
  Future<void> cikisYap() async {
    await servis.cikisYap();
    state = state.kopyala(girisYaptiMi: false);
  }
}

final StateNotifierProvider<KimlikDenetleyici, KimlikDurumu> kimlikSaglayici = StateNotifierProvider<KimlikDenetleyici, KimlikDurumu>((Ref ref) {
  throw UnimplementedError('DI ile sağlanmalı');
});

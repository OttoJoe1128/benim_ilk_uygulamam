// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/bitki_analiz_repository.dart';
import '../../domain/entities/bitki_analiz_sonucu.dart';
import '../../../../core/crypto/hash_util.dart';
import '../../../../core/blockchain/zincir_servisi.dart';

class BitkiDurumu {
  final bool yukleniyorMu;
  final String hata;
  final BitkiAnalizSonucu? sonuc;
  const BitkiDurumu({required this.yukleniyorMu, required this.hata, required this.sonuc});
  BitkiDurumu kopyala({bool? yukleniyorMu, String? hata, BitkiAnalizSonucu? sonuc}) {
    return BitkiDurumu(yukleniyorMu: yukleniyorMu ?? this.yukleniyorMu, hata: hata ?? this.hata, sonuc: sonuc ?? this.sonuc);
  }
}

class BitkiDenetleyici extends StateNotifier<BitkiDurumu> {
  final BitkiAnalizHavuzu havuz;
  final ZincirServisi? zincir;
  BitkiDenetleyici({required this.havuz, this.zincir}) : super(const BitkiDurumu(yukleniyorMu: false, hata: '', sonuc: null));
  Future<void> analizEt({required String goruntuYolu}) async {
    state = state.kopyala(yukleniyorMu: true, hata: '', sonuc: null);
    try {
      final BitkiAnalizSonucu sonuc = await havuz.analizEt(goruntuDosyaYolu: goruntuYolu);
      final String oz = OzEtUtil.ureteSha256(icerik: '${sonuc.turAdi}|${sonuc.guvenPuani}|${sonuc.etiketler.join(',')}');
      if (zincir != null) {
        await zincir!.hashYayinla(ozEt: oz);
      }
      state = state.kopyala(yukleniyorMu: false, sonuc: sonuc);
    } catch (e) {
      state = state.kopyala(yukleniyorMu: false, hata: e.toString());
    }
  }
}

final StateNotifierProvider<BitkiDenetleyici, BitkiDurumu> bitkiSaglayici = StateNotifierProvider<BitkiDenetleyici, BitkiDurumu>((Ref ref) {
  throw UnimplementedError('DI ile sağlanmalı');
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adaptif UI modlar?n? temsil eden enum.
enum AdaptifUiModu { detayli, sade }

/// Adaptif UI durumunu ta??yan model s?n?f?.
class AdaptifUiDurumu {
  final Set<String> aktifKartKimlikleri;
  final Duration kullanimSuresi;
  final AdaptifUiModu mod;
  const AdaptifUiDurumu({required this.aktifKartKimlikleri, required this.kullanimSuresi, required this.mod});

  AdaptifUiDurumu kopyaOlustur({Set<String>? aktifKartKimlikleri, Duration? kullanimSuresi, AdaptifUiModu? mod}) {
    return AdaptifUiDurumu(
      aktifKartKimlikleri: aktifKartKimlikleri ?? this.aktifKartKimlikleri,
      kullanimSuresi: kullanimSuresi ?? this.kullanimSuresi,
      mod: mod ?? this.mod,
    );
  }
}

/// Kullan?m al??kanl?klar?na g?re kart g?r?n?rl???n? y?neten denetleyici.
class AdaptifTemaYoneticisi extends StateNotifier<AdaptifUiDurumu> {
  static const Set<String> varsayilanKartlar = <String>{'hava', 'sensor', 'senkron', 'ai'};
  static const Duration zamanEsigi = Duration(minutes: 5);
  static const int tiklamaEsigi = 3;
  AdaptifTemaYoneticisi()
      : super(const AdaptifUiDurumu(aktifKartKimlikleri: <String>{'hava', 'sensor', 'senkron', 'ai'}, kullanimSuresi: Duration.zero, mod: AdaptifUiModu.detayli));

  void guncelleKullanim({required Duration sureArtisi, required int tiklamaArtisi}) {
    final Duration yeniSure = state.kullanimSuresi + sureArtisi;
    final bool sadeMod = yeniSure >= zamanEsigi && tiklamaArtisi <= tiklamaEsigi;
    final Set<String> aktifKartSeti = <String>{...state.aktifKartKimlikleri};
    if (sadeMod) {
      aktifKartSeti.remove('hava');
    }
    state = state.kopyaOlustur(aktifKartKimlikleri: aktifKartSeti, kullanimSuresi: yeniSure, mod: sadeMod ? AdaptifUiModu.sade : AdaptifUiModu.detayli);
  }

  void sifirla() {
    state = AdaptifUiDurumu(aktifKartKimlikleri: varsayilanKartlar, kullanimSuresi: Duration.zero, mod: AdaptifUiModu.detayli);
  }

  void kartiGoster({required String kartKimligi}) {
    final Set<String> yeniKartlar = <String>{...state.aktifKartKimlikleri}..add(kartKimligi);
    state = state.kopyaOlustur(aktifKartKimlikleri: yeniKartlar);
  }

  void kartiGizle({required String kartKimligi}) {
    final Set<String> yeniKartlar = <String>{...state.aktifKartKimlikleri}..remove(kartKimligi);
    state = state.kopyaOlustur(aktifKartKimlikleri: yeniKartlar);
  }
}

/// Adaptif UI sa?lay?c?s?.
final StateNotifierProvider<AdaptifTemaYoneticisi, AdaptifUiDurumu> adaptifUiProvider = StateNotifierProvider<AdaptifTemaYoneticisi, AdaptifUiDurumu>((Ref ref) {
  return AdaptifTemaYoneticisi();
});

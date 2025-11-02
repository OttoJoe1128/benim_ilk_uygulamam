import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/features/harita/denetleyiciler/sulama_cizim_durumu.dart';
import 'package:nova_agro/features/harita/depocular/sulama_cizim_deposu.dart';
import 'package:nova_agro/features/harita/senkronizasyon/senkron_yoneticisi.dart';

class SulamaCizimDenetleyici extends StateNotifier<SulamaCizimDurumu> {
  final SulamaCizimDeposu sulamaCizimDeposu;
  final SenkronYoneticisi senkronYoneticisi;

  SulamaCizimDenetleyici({
    required this.sulamaCizimDeposu,
    required this.senkronYoneticisi,
  }) : super(SulamaCizimDurumu.ilk());

  Future<void> yukleNoktalar() async {
    final List<LatLng> kayitli = await sulamaCizimDeposu.getirNoktalar();
    state = state.kopyala(noktalar: kayitli);
    await senkronYoneticisi.senkronizeBekleyenIslemler();
  }

  void baslatCizim() {
    if (state.isCizimAcik) {
      state = state.kopyala(isCizimAcik: false);
      return;
    }
    state = state.kopyala(isCizimAcik: true);
  }

  void ekleNokta({required LatLng nokta}) {
    if (!state.isCizimAcik) {
      return;
    }
    final List<LatLng> guncel = List<LatLng>.from(state.noktalar)..add(nokta);
    state = state.kopyala(noktalar: guncel);
    unawaited(sulamaCizimDeposu.kaydetNoktalar(noktalar: guncel));
    unawaited(senkronYoneticisi.senkronizeSulamaKaydet(noktalar: guncel));
  }

  void geriAl() {
    if (state.noktalar.isEmpty) {
      return;
    }
    final List<LatLng> guncel = List<LatLng>.from(state.noktalar)..removeLast();
    state = state.kopyala(noktalar: guncel);
    unawaited(sulamaCizimDeposu.kaydetNoktalar(noktalar: guncel));
    unawaited(senkronYoneticisi.senkronizeSulamaKaydet(noktalar: guncel));
  }

  void temizle() {
    state = state.kopyala(noktalar: <LatLng>[]);
    unawaited(sulamaCizimDeposu.kaydetNoktalar(noktalar: <LatLng>[]));
    unawaited(senkronYoneticisi.senkronizeSulamaKaydet(noktalar: <LatLng>[]));
  }
}

final StateNotifierProvider<SulamaCizimDenetleyici, SulamaCizimDurumu>
sulamaCizimDenetleyiciProvider =
    StateNotifierProvider<SulamaCizimDenetleyici, SulamaCizimDurumu>((Ref ref) {
      final SulamaCizimDeposu depo = hizmetBulucu<SulamaCizimDeposu>();
      final SenkronYoneticisi senkronYoneticisi =
          hizmetBulucu<SenkronYoneticisi>();
      return SulamaCizimDenetleyici(
        sulamaCizimDeposu: depo,
        senkronYoneticisi: senkronYoneticisi,
      );
    });

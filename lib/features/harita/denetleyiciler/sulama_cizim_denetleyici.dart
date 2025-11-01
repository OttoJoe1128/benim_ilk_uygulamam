import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/features/harita/denetleyiciler/sulama_cizim_durumu.dart';
import 'package:nova_agro/features/harita/depocular/sulama_cizim_deposu.dart';

class SulamaCizimDenetleyici extends StateNotifier<SulamaCizimDurumu> {
  final SulamaCizimDeposu sulamaCizimDeposu;

  SulamaCizimDenetleyici({required this.sulamaCizimDeposu})
    : super(SulamaCizimDurumu.ilk());

  Future<void> yukleNoktalar() async {
    final List<LatLng> kayitli = await sulamaCizimDeposu.getirNoktalar();
    state = state.kopyala(noktalar: kayitli);
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
  }

  void geriAl() {
    if (state.noktalar.isEmpty) {
      return;
    }
    final List<LatLng> guncel = List<LatLng>.from(state.noktalar)..removeLast();
    state = state.kopyala(noktalar: guncel);
    unawaited(sulamaCizimDeposu.kaydetNoktalar(noktalar: guncel));
  }

  void temizle() {
    state = state.kopyala(noktalar: <LatLng>[]);
    unawaited(sulamaCizimDeposu.kaydetNoktalar(noktalar: <LatLng>[]));
  }
}

final StateNotifierProvider<SulamaCizimDenetleyici, SulamaCizimDurumu>
sulamaCizimDenetleyiciProvider =
    StateNotifierProvider<SulamaCizimDenetleyici, SulamaCizimDurumu>((Ref ref) {
      final SulamaCizimDeposu depo = hizmetBulucu<SulamaCizimDeposu>();
      return SulamaCizimDenetleyici(sulamaCizimDeposu: depo);
    });

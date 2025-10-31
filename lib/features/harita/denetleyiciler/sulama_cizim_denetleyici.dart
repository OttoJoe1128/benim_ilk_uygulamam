import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/sulama_cizim_durumu.dart';

class SulamaCizimDenetleyici extends StateNotifier<SulamaCizimDurumu> {
  SulamaCizimDenetleyici() : super(SulamaCizimDurumu.ilk());

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
  }

  void geriAl() {
    if (state.noktalar.isEmpty) {
      return;
    }
    final List<LatLng> guncel = List<LatLng>.from(state.noktalar)..removeLast();
    state = state.kopyala(noktalar: guncel);
  }

  void temizle() {
    state = state.kopyala(noktalar: <LatLng>[]);
  }
}

final StateNotifierProvider<SulamaCizimDenetleyici, SulamaCizimDurumu>
sulamaCizimDenetleyiciProvider =
    StateNotifierProvider<SulamaCizimDenetleyici, SulamaCizimDurumu>((Ref ref) {
      return SulamaCizimDenetleyici();
    });

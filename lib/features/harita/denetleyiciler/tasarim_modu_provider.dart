import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:benim_ilk_uygulamam/features/harita/denetleyiciler/tasarim_modu.dart';

final StateProvider<TasarimModu> tasarimModuProvider =
    StateProvider<TasarimModu>((Ref ref) {
      return TasarimModu.hicbiri;
    });

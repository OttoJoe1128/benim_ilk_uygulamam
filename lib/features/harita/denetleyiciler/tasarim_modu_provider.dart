import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_agro/features/harita/denetleyiciler/tasarim_modu.dart';

final StateProvider<TasarimModu> tasarimModuProvider =
    StateProvider<TasarimModu>((Ref ref) {
      return TasarimModu.hicbiri;
    });

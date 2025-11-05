import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:benim_ilk_uygulamam/core/di/hizmet_bulucu.dart';
import 'package:benim_ilk_uygulamam/features/harita/veri_kaynaklari/open_meteo_servisi.dart';

/// GetIt ?zerinden OpenMeteoServisi sa?layan Riverpod provider.
final Provider<OpenMeteoServisi> openMeteoServisiProvider = Provider<OpenMeteoServisi>((Ref ref) {
  return kurHizmetBulucu<OpenMeteoServisi>();
});

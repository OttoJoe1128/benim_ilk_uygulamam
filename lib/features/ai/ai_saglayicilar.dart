import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:benim_ilk_uygulamam/core/di/hizmet_bulucu.dart';
import 'package:benim_ilk_uygulamam/features/ai/depocular/sensor_sqlite_deposu.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/nova_ai_karari.dart';
import 'package:benim_ilk_uygulamam/features/ai/modeller/sensor_olcumu.dart';
import 'package:benim_ilk_uygulamam/features/ai/nova_ai_servisi.dart';

/// GetIt ?zerinden Nova AI servislerini sa?layan Riverpod provider.
final Provider<NovaAiServisi> novaAiServisiProvider = Provider<NovaAiServisi>((Ref ref) {
  return kurHizmetBulucu<NovaAiServisi>();
});

/// Nova AI servisinden son karar? ?eken Future provider.
final FutureProvider<NovaAiKarari?> novaAiSonKararProvider = FutureProvider<NovaAiKarari?>((Ref ref) async {
  final NovaAiServisi servis = ref.watch(novaAiServisiProvider);
  final NovaAiKarari? karar = await servis.analizEtSonKayit();
  return karar;
});

/// Sens?r deposundan son ?l??m? ?eken Future provider.
final FutureProvider<SensorOlcumu?> sensorSonOlcumProvider = FutureProvider<SensorOlcumu?>((Ref ref) async {
  final SensorSqliteDeposu depo = kurHizmetBulucu<SensorSqliteDeposu>();
  final SensorOlcumu? olcum = await depo.getirSonOlcum();
  return olcum;
});

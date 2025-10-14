import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../features/pano/data/depolar/pano_deposu_bellek.dart';
import '../../features/pano/domain/sozlesmeler/pano_deposu.dart';
import '../../features/sohbet/data/depolar/sohbet_deposu_bellek.dart';
import '../../features/sohbet/domain/sozlesmeler/sohbet_deposu.dart';

final GetIt servisBulucu = GetIt.instance;

void baslatServisBulucu() {
  if (!servisBulucu.isRegistered<Uuid>()) {
    servisBulucu.registerLazySingleton<Uuid>(() => const Uuid());
  }
  if (!servisBulucu.isRegistered<PanoDeposu>()) {
    servisBulucu.registerLazySingleton<PanoDeposu>(() => PanoDeposuBellek(uuid: servisBulucu.get<Uuid>()));
  }
  if (!servisBulucu.isRegistered<SohbetDeposu>()) {
    servisBulucu.registerLazySingleton<SohbetDeposu>(() => SohbetDeposuBellek(uuid: servisBulucu.get<Uuid>()));
  }
}

import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/pano/data/depolar/pano_deposu_bellek.dart';
import '../../features/pano/data/depolar/pano_deposu_firestore.dart';
import '../../features/pano/domain/sozlesmeler/pano_deposu.dart';
import '../../features/sohbet/data/depolar/sohbet_deposu_bellek.dart';
import '../../features/sohbet/data/depolar/sohbet_deposu_firestore.dart';
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

Future<void> etkinlestirFirebaseServisleri({bool zorunlu = false}) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    await FirebaseAuth.instance.signInAnonymously();
    if (!servisBulucu.isRegistered<FirebaseFirestore>()) {
      servisBulucu.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    }
    if (servisBulucu.isRegistered<PanoDeposu>()) {
      servisBulucu.unregister<PanoDeposu>();
    }
    if (servisBulucu.isRegistered<SohbetDeposu>()) {
      servisBulucu.unregister<SohbetDeposu>();
    }
    servisBulucu.registerLazySingleton<PanoDeposu>(() =>
        PanoDeposuFirestore(firestore: servisBulucu.get<FirebaseFirestore>(), uuidUretici: servisBulucu.get<Uuid>()));
    servisBulucu.registerLazySingleton<SohbetDeposu>(() =>
        SohbetDeposuFirestore(firestore: servisBulucu.get<FirebaseFirestore>(), uuidUretici: servisBulucu.get<Uuid>()));
  } catch (e) {
    if (zorunlu) rethrow;
    // Firebase başarısızsa bellek deposunda kal
  }
}

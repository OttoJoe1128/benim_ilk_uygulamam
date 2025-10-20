import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../ag/ag_istemcisi.dart';
import '../../features/bitki_analizi/data/datasources/model_veri_kaynagi.dart';
import '../../features/bitki_analizi/data/repositories/bitki_tani_deposu_impl.dart';
import '../../features/bitki_analizi/domain/repositories/bitki_tani_deposu.dart';
import '../../features/bitki_analizi/domain/usecases/tani_yap.dart';

final GetIt bagimlilikCozumleyici = GetIt.instance;

Future<void> kurBagimliliklar() async {
  bagimlilikCozumleyici.registerLazySingleton<Dio>(() => olusturAgIstemcisi());
  bagimlilikCozumleyici.registerLazySingleton<ModelVeriKaynagi>(() => SahteModelVeriKaynagi());
  bagimlilikCozumleyici.registerLazySingleton<BitkiTaniDeposu>(
    () => BitkiTaniDeposuImpl(modelVeriKaynagi: bagimlilikCozumleyici<ModelVeriKaynagi>()),
  );
  bagimlilikCozumleyici.registerFactory<TaniYapUseCase>(
    () => TaniYapUseCase(depo: bagimlilikCozumleyici<BitkiTaniDeposu>()),
  );
}

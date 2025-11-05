// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../features/github/data/github_remote_data_source.dart';
import '../features/github/data/github_repository_impl.dart';
import '../features/github/domain/github_repository.dart';

final GetIt servisBulucu = GetIt.instance;

void baslatBagimliliklar() {
  if (!servisBulucu.isRegistered<DioIstemcisi>()) {
    servisBulucu.registerLazySingleton<DioIstemcisi>(() => DioIstemcisi.olustur());
  }
  if (!servisBulucu.isRegistered<Dio>()) {
    servisBulucu.registerLazySingleton<Dio>(() => servisBulucu<DioIstemcisi>().dio);
  }
  if (!servisBulucu.isRegistered<GitHubUzakVeriKaynagi>()) {
    servisBulucu.registerLazySingleton<GitHubUzakVeriKaynagi>(() => GitHubUzakVeriKaynagi(dio: servisBulucu<Dio>()));
  }
  if (!servisBulucu.isRegistered<GitHubHavuzu>()) {
    servisBulucu.registerLazySingleton<GitHubHavuzu>(() => GitHubHavuzuGercek(uzakVeriKaynagi: servisBulucu<GitHubUzakVeriKaynagi>()));
  }
}

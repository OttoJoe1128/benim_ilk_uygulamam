// ignore_for_file: public_member_api_docs

import 'entities/github_repository_entity.dart';

abstract class GitHubHavuzu {
  Future<List<GitHubDepoVarlik>> araDepolar({required String sorgu, String dil = '', String siralama = 'stars', int sayfa = 1, int sayfaBoyutu = 30});
  Future<GitHubDepoVarlik> getirDepoDetay({required String sahip, required String depo});
}

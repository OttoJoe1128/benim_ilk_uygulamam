// ignore_for_file: public_member_api_docs

import '../domain/github_repository.dart';
import '../domain/entities/github_repository_entity.dart';
import 'github_remote_data_source.dart';

class GitHubHavuzuGercek implements GitHubHavuzu {
  final GitHubUzakVeriKaynagi uzakVeriKaynagi;
  GitHubHavuzuGercek({required this.uzakVeriKaynagi});
  @override
  Future<List<GitHubDepoVarlik>> araDepolar({required String sorgu, String dil = '', String siralama = 'stars', int sayfa = 1, int sayfaBoyutu = 30}) {
    return uzakVeriKaynagi.araDepolar(sorgu: sorgu, dil: dil, siralama: siralama, sayfa: sayfa, sayfaBoyutu: sayfaBoyutu);
  }
  @override
  Future<GitHubDepoVarlik> getirDepoDetay({required String sahip, required String depo}) {
    return uzakVeriKaynagi.getirDepoDetay(sahip: sahip, depo: depo);
  }
}

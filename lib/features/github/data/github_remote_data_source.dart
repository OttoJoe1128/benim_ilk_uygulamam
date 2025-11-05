// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart';
import '../../github/domain/entities/github_repository_entity.dart';

class GitHubUzakVeriKaynagi {
  final Dio dio;
  GitHubUzakVeriKaynagi({required this.dio});
  Future<List<GitHubDepoVarlik>> araDepolar({required String sorgu, String dil = '', String siralama = 'stars', int sayfa = 1, int sayfaBoyutu = 30}) async {
    final Map<String, dynamic> parametreler = {
      'q': sorgu + (dil.isNotEmpty ? ' language:$dil' : ''),
      'sort': siralama,
      'page': sayfa,
      'per_page': sayfaBoyutu,
    };
    final Response<dynamic> res = await dio.get('/search/repositories', queryParameters: parametreler);
    final List<dynamic> ogeler = res.data['items'] as List<dynamic>;
    return ogeler.map((dynamic e) {
      return GitHubDepoVarlik(
        ad: e['name'] as String? ?? '',
        sahip: (e['owner']?['login'] as String?) ?? '',
        aciklama: e['description'] as String? ?? '',
        yildizSayisi: e['stargazers_count'] as int? ?? 0,
        catiSayisi: e['forks_count'] as int? ?? 0,
        acikKonuSayisi: e['open_issues_count'] as int? ?? 0,
        url: e['html_url'] as String? ?? '',
      );
    }).toList();
  }
  Future<GitHubDepoVarlik> getirDepoDetay({required String sahip, required String depo}) async {
    final Response<dynamic> res = await dio.get('/repos/$sahip/$depo');
    final dynamic e = res.data;
    return GitHubDepoVarlik(
      ad: e['name'] as String? ?? '',
      sahip: (e['owner']?['login'] as String?) ?? '',
      aciklama: e['description'] as String? ?? '',
      yildizSayisi: e['stargazers_count'] as int? ?? 0,
      catiSayisi: e['forks_count'] as int? ?? 0,
      acikKonuSayisi: e['open_issues_count'] as int? ?? 0,
      url: e['html_url'] as String? ?? '',
    );
  }
}

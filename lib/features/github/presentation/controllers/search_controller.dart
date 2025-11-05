// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../github/domain/github_repository.dart';
import '../../../github/domain/entities/github_repository_entity.dart';

class AramaDurumu {
  final bool yukleniyorMu;
  final String hataMesaji;
  final List<GitHubDepoVarlik> sonuclar;
  const AramaDurumu({required this.yukleniyorMu, required this.hataMesaji, required this.sonuclar});
  AramaDurumu kopyala({bool? yukleniyorMu, String? hataMesaji, List<GitHubDepoVarlik>? sonuclar}) {
    return AramaDurumu(
      yukleniyorMu: yukleniyorMu ?? this.yukleniyorMu,
      hataMesaji: hataMesaji ?? this.hataMesaji,
      sonuclar: sonuclar ?? this.sonuclar,
    );
  }
}

class AramaDenetleyici extends StateNotifier<AramaDurumu> {
  final GitHubHavuzu havuz;
  AramaDenetleyici({required this.havuz}) : super(const AramaDurumu(yukleniyorMu: false, hataMesaji: '', sonuclar: []));
  Future<void> araDepoListesiniGuncelle({required String sorgu}) async {
    if (sorgu.trim().isEmpty) {
      state = const AramaDurumu(yukleniyorMu: false, hataMesaji: '', sonuclar: []);
      return;
    }
    state = state.kopyala(yukleniyorMu: true, hataMesaji: '');
    try {
      final List<GitHubDepoVarlik> sonuclar = await havuz.araDepolar(sorgu: sorgu);
      state = state.kopyala(yukleniyorMu: false, sonuclar: sonuclar);
    } catch (e) {
      state = state.kopyala(yukleniyorMu: false, hataMesaji: e.toString());
    }
  }
}

final StateNotifierProvider<AramaDenetleyici, AramaDurumu> aramaSaglayici = StateNotifierProvider<AramaDenetleyici, AramaDurumu>((Ref ref) {
  throw UnimplementedError('DI ile sağlanmalı');
});

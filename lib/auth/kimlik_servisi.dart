// ignore_for_file: public_member_api_docs

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KimlikServisi {
  final FlutterSecureStorage secure;
  static const String _anahtar = 'ozel_anahtar';
  KimlikServisi({required this.secure});
  Future<bool> isGirisYapildiMi() async {
    final String? pk = await secure.read(key: _anahtar);
    return pk != null && pk.isNotEmpty;
  }
  Future<void> anahtarKaydet({required String ozelAnahtar}) async {
    await secure.write(key: _anahtar, value: ozelAnahtar);
  }
  Future<String?> anahtarGetir() async {
    final String? pk = await secure.read(key: _anahtar);
    return pk;
  }
  Future<void> cikisYap() async {
    await secure.delete(key: _anahtar);
  }
}

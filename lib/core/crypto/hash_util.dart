// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

class OzEtUtil {
  static String ureteSha256({required String icerik}) {
    final List<int> baytlar = utf8.encode(icerik);
    final String oz = crypto.sha256.convert(baytlar).toString();
    return oz;
  }
}

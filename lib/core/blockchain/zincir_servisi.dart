// ignore_for_file: public_member_api_docs

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ZincirServisi {
  final Web3Client istemci;
  final EthPrivateKey? ozelAnahtar;
  ZincirServisi._(this.istemci, this.ozelAnahtar);
  factory ZincirServisi.olustur() {
    final String? rpc = dotenv.maybeGet('RPC_URL');
    if (rpc == null || rpc.isEmpty) {
      throw Exception('RPC_URL tanımsız');
    }
    final Web3Client istemci = Web3Client(rpc, http.Client());
    final String? pk = dotenv.maybeGet('PRIVATE_KEY');
    final EthPrivateKey? anahtar = (pk != null && pk.isNotEmpty) ? EthPrivateKey.fromHex(pk) : null;
    return ZincirServisi._(istemci, anahtar);
  }
  Future<String?> hashYayinla({required String ozEt}) async {
    if (ozelAnahtar == null) return null;
    final EthereumAddress adres = await ozelAnahtar!.extractAddress();
    final Transaction islem = Transaction(to: adres, value: EtherAmount.zero(), data: Uint8List.fromList(ozEt.codeUnits));
    final String txHash = await istemci.sendTransaction(ozelAnahtar!, islem, chainId: null);
    return txHash;
  }
}

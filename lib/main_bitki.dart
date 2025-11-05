// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'di/locator.dart';
import 'auth/kimlik_controller.dart';
import 'auth/kimlik_sayfasi.dart';
import 'auth/kimlik_servisi.dart';
import 'features/bitki_analiz/presentation/controllers/bitki_controller.dart';
import 'features/bitki_analiz/presentation/pages/bitki_page.dart';
import 'features/bitki_analiz/data/plantid_remote_data_source.dart';
import 'features/bitki_analiz/data/bitki_analiz_repository_impl.dart';
import 'features/bitki_analiz/domain/bitki_analiz_repository.dart';
import 'core/blockchain/zincir_servisi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env/.env');
  baslatBagimliliklar();
  runApp(const SaglayiciUygulama());
}

class SaglayiciUygulama extends StatefulWidget {
  const SaglayiciUygulama({super.key});
  @override
  State<SaglayiciUygulama> createState() => _SaglayiciUygulamaDurumu();
}

class _SaglayiciUygulamaDurumu extends State<SaglayiciUygulama> {
  final FlutterSecureStorage secure = const FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: <Override>[
        kimlikSaglayici.overrideWith((Ref ref) => KimlikDenetleyici(servis: KimlikServisi(secure: secure))),
        bitkiSaglayici.overrideWith((Ref ref) {
          final PlantIdUzakVeriKaynagi uzak = PlantIdUzakVeriKaynagi(dio: servisBulucu());
          final BitkiAnalizHavuzu havuz = BitkiAnalizHavuzuGercek(uzakKaynagi: uzak);
          ZincirServisi? zincir;
          try { zincir = ZincirServisi.olustur(); } catch (_) { zincir = null; }
          return BitkiDenetleyici(havuz: havuz, zincir: zincir);
        }),
      ],
      child: const Uygulama(),
    );
  }
}

class Uygulama extends ConsumerStatefulWidget {
  const Uygulama({super.key});
  @override
  ConsumerState<Uygulama> createState() => _UygulamaDurumu();
}

class _UygulamaDurumu extends ConsumerState<Uygulama> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kimlikSaglayici.notifier).durumuYukle();
    });
  }
  @override
  Widget build(BuildContext context) {
    final KimlikDurumu kimlik = ref.watch(kimlikSaglayici);
    return MaterialApp(
      title: 'Bitki Analiz',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: KimlikSayfasi(hedef: const BitkiAnalizSayfasi()),
      // Eğer giriş kontrolü yapmak isterseniz: kimlik.girisYaptiMi ? BitkiAnalizSayfasi() : KimlikSayfasi(...)
    );
  }
}

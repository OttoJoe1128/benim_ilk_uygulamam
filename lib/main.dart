import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/bagimliliklar.dart';
import 'core/sabitler/uygulama_sabitleri.dart';
import 'core/tema/tema.dart';
import 'features/bitki_analizi/presentation/sayfalar/ana_sayfa.dart';
import 'features/bitki_analizi/presentation/sayfalar/cekim_sayfasi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await kurBagimliliklar();
  runApp(const ProviderScope(child: Uygulama()));
}

class Uygulama extends StatelessWidget {
  const Uygulama({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: UygulamaSabitleri.uygulamaAdi,
      theme: olusturTemayi(),
      routes: <String, WidgetBuilder>{
        UygulamaSabitleri.rotaAnaSayfa: (_) => const AnaSayfa(),
        UygulamaSabitleri.rotaCekim: (_) => const CekimSayfasi(),
      },
      initialRoute: UygulamaSabitleri.rotaAnaSayfa,
    );
  }
}

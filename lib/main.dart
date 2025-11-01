import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/core/tema/uygulama_tema.dart';
import 'package:nova_agro/core/yerellestirme/uygulama_dilleri.dart';
import 'package:nova_agro/core/yonlendirme/uygulama_router.dart';
import 'package:nova_agro/features/harita/harita_modulu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  kurHizmetBulucu(moduller: <ModulKaydedici>[kurHaritaModulu]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final UygulamaRouter _router = UygulamaRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nova Agro',
      theme: UygulamaTema.hazirlaAydinlikTema(),
      darkTheme: UygulamaTema.hazirlaKoyuTema(),
      routerConfig: _router.config(),
      locale: UygulamaDilleri.varsayilanYerel,
      supportedLocales: UygulamaDilleri.desteklenenYerelleriGetir(),
      localizationsDelegates: UygulamaDilleri.yerellestirmeDelegeleriniGetir(),
    );
  }
}

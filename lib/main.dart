import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/servis_bulucu.dart';
import 'core/routing/app_router.dart';
import 'core/theme/uygulama_temasi.dart';

void main() {
  baslatServisBulucu();
  // Firebase'i arka planda dene, başarısız olursa bellek depolarıyla devam
  etkinlestirFirebaseServisleri();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouter();
    return MaterialApp.router(
      title: 'Anonim Panolar',
      theme: olusturTema(),
      routerConfig: router.config(),
    );
  }
}

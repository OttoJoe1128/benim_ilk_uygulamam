// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/features/harita/depocular/sensor_bellek_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sensor_deposu.dart';
import 'package:nova_agro/features/harita/depocular/senkron_islem_bellek_deposu.dart';
import 'package:nova_agro/features/harita/depocular/senkron_islem_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sulama_cizim_bellek_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sulama_cizim_deposu.dart';
import 'package:nova_agro/features/harita/harita_modulu.dart';
import 'package:nova_agro/features/harita/servisler/nova_cloud_servisi.dart';
import 'package:nova_agro/features/harita/senkronizasyon/senkron_yoneticisi.dart';
import 'package:nova_agro/main.dart';

void main() {
  setUp(() async {
    await hizmetBulucu.reset(dispose: true);
    kurHizmetBulucu(moduller: <ModulKaydedici>[kurHaritaModulu]);
    await hizmetBulucu.unregister<SensorDeposu>();
    await hizmetBulucu.unregister<SulamaCizimDeposu>();
    await hizmetBulucu.unregister<SenkronIslemDeposu>();
    await hizmetBulucu.unregister<NovaCloudServisi>();
    await hizmetBulucu.unregister<SenkronYoneticisi>();
    await hizmetBulucu.unregister<Dio>();
    hizmetBulucu.registerLazySingleton<SensorDeposu>(SensorBellekDeposu.new);
    hizmetBulucu.registerLazySingleton<SulamaCizimDeposu>(
      SulamaCizimBellekDeposu.new,
    );
    hizmetBulucu.registerLazySingleton<SenkronIslemDeposu>(
      SenkronIslemBellekDeposu.new,
    );
    hizmetBulucu.registerLazySingleton<Dio>(Dio.new);
    hizmetBulucu.registerLazySingleton<NovaCloudServisi>(
      () => NovaCloudServisiFake(dio: hizmetBulucu<Dio>(), hataOlasiligi: 0),
    );
    hizmetBulucu.registerLazySingleton<SenkronYoneticisi>(
      () => SenkronYoneticisi(
        novaCloudServisi: hizmetBulucu<NovaCloudServisi>(),
        senkronIslemDeposu: hizmetBulucu<SenkronIslemDeposu>(),
      ),
    );
  });

  testWidgets('Harita ekranı başlatma testi', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    expect(find.text('Nova Agro – Harita'), findsOneWidget);
    expect(find.text('Bul'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_agro/core/di/hizmet_bulucu.dart';
import 'package:nova_agro/main.dart';
import 'package:nova_agro/features/harita/harita_modulu.dart';
import 'package:nova_agro/features/harita/depocular/sensor_bellek_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sensor_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sulama_cizim_bellek_deposu.dart';
import 'package:nova_agro/features/harita/depocular/sulama_cizim_deposu.dart';

void main() {
  setUp(() async {
    await hizmetBulucu.reset(dispose: true);
    kurHizmetBulucu(moduller: <ModulKaydedici>[kurHaritaModulu]);
    await hizmetBulucu.unregister<SensorDeposu>();
    await hizmetBulucu.unregister<SulamaCizimDeposu>();
    hizmetBulucu.registerLazySingleton<SensorDeposu>(SensorBellekDeposu.new);
    hizmetBulucu.registerLazySingleton<SulamaCizimDeposu>(
      SulamaCizimBellekDeposu.new,
    );
  });

  testWidgets('Harita ekranı başlatma testi', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    expect(find.text('Nova Agro – Harita'), findsOneWidget);
    expect(find.text('Bul'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:benim_ilk_uygulamam/core/di/hizmet_bulucu.dart';
import 'package:benim_ilk_uygulamam/main.dart';
import 'package:benim_ilk_uygulamam/features/harita/harita_modulu.dart';

void main() {
  setUp(() async {
    await hizmetBulucu.reset(dispose: true);
    kurHizmetBulucu(moduller: <ModulKaydedici>[kurHaritaModulu]);
  });

  testWidgets('Harita ekranı başlatma testi', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    expect(find.text('Nova Agro – Harita'), findsOneWidget);
    expect(find.text('Bul'), findsOneWidget);
  });
}

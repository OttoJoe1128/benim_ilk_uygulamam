import 'package:auto_route/auto_route.dart';

import 'package:benim_ilk_uygulamam/features/harita/sunuma/harita_sayfasi.dart';

part 'uygulama_router.gr.dart';

@AutoRouterConfig()
class UygulamaRouter extends RootStackRouter {
  UygulamaRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: HaritaRoute.page, initial: true),
  ];
}

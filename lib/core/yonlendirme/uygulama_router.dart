import 'package:auto_route/auto_route.dart';

import 'package:benim_ilk_uygulamam/features/harita/sunuma/harita_sayfasi.dart';

class UygulamaRouter extends RootStackRouter {
  UygulamaRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = <String, PageFactory>{
    HaritaRoute.name: (RouteData routeData) => AutoRoutePage<dynamic>(routeData: routeData, child: const HaritaEkraniKapsayici()),
  };

  @override
  List<RouteConfig> get routes => <RouteConfig>[RouteConfig(HaritaRoute.name, path: '/')];
}

class HaritaRoute extends PageRouteInfo<void> {
  const HaritaRoute() : super(name, path: '/');

  static const String name = 'HaritaRoute';
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/pano/presentation/sayfalar/pano_listesi_sayfasi.dart';
import '../../features/pano/presentation/sayfalar/pano_olustur_sayfasi.dart';
import '../../features/pano/presentation/sayfalar/pano_sayfasi.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Sayfasi,Route')
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: PanoListesiRoute.page, path: '/'),
        AutoRoute(page: PanoOlusturRoute.page, path: '/olustur'),
        AutoRoute(page: PanoRoute.page, path: '/pano/:id'),
      ];
}

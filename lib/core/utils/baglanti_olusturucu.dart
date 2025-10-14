import 'package:flutter/foundation.dart';

String olusturPanoBaglantisi({required String panoId, bool saltOkunur = false}) {
  final String ro = saltOkunur ? '?ro=1' : '';
  final String hashPath = '#/pano/$panoId$ro';
  final String origin = Uri.base.origin;
  final String basePath = kIsWeb ? Uri.base.path : '';
  return '$origin$basePath$hashPath';
}

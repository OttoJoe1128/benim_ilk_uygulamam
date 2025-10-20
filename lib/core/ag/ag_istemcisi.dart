import 'package:dio/dio.dart';

Dio olusturAgIstemcisi() {
  final BaseOptions secenekler = BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    headers: <String, Object>{'Accept': 'application/json'},
  );
  return Dio(secenekler);
}

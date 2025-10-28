// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';

class DioIstemcisi {
  final Dio dio;
  DioIstemcisi({required Dio dio}) : dio = dio;
  factory DioIstemcisi.olustur() {
    final BaseOptions secenekler = BaseOptions(
      baseUrl: UygulamaSabitleri.githubApiTabaniUrl,
      connectTimeout: UygulamaSabitleri.agZamaniAsimi,
      receiveTimeout: UygulamaSabitleri.agZamaniAsimi,
      sendTimeout: UygulamaSabitleri.agZamaniAsimi,
      headers: {
        'Accept': 'application/vnd.github+json',
      },
    );
    final Dio istemci = Dio(secenekler);
    final String? token = dotenv.maybeGet('GITHUB_TOKEN');
    if (token != null && token.isNotEmpty) {
      istemci.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      }));
    }
    istemci.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
    return DioIstemcisi(dio: istemci);
  }
}

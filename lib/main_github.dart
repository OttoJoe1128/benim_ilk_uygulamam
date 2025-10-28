// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'di/locator.dart';
import 'features/github/presentation/pages/search_page.dart';
import 'features/github/presentation/controllers/search_controller.dart';
import 'features/github/domain/github_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env/.env');
  baslatBagimliliklar();
  runApp(const SaglayiciUygulama());
}

class SaglayiciUygulama extends StatelessWidget {
  const SaglayiciUygulama({super.key});
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: <Override>[
        aramaSaglayici.overrideWith((Ref ref) {
          final GitHubHavuzu havuz = servisBulucu<GitHubHavuzu>();
          return AramaDenetleyici(havuz: havuz);
        })
      ],
      child: const Uygulama(),
    );
  }
}

class Uygulama extends StatelessWidget {
  const Uygulama({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Gezgini',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const AramaSayfasi(),
    );
  }
}

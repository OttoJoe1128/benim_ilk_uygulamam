// Bu dosya, flutterfire CLI tarafından üretilmiş gibi davranan bir yer tutucudur.
// Gerçek projede FlutterFire CLI ile oluşturulması gerekir.

import 'package:flutter/foundation.dart' show immutable;

@immutable
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    throw UnimplementedError('FlutterFire seçenekleri ayarlı değil.');
  }
}

class FirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String authDomain;
  final String storageBucket;
  final String iosBundleId;
  const FirebaseOptions({required this.apiKey, required this.appId, required this.messagingSenderId, required this.projectId, this.authDomain = '', this.storageBucket = '', this.iosBundleId = ''});
}

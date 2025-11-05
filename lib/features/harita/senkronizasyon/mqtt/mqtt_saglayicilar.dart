import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:benim_ilk_uygulamam/core/di/hizmet_bulucu.dart';
import 'package:benim_ilk_uygulamam/features/harita/senkronizasyon/mqtt/mqtt_senkron_servisi.dart';

/// GetIt ?zerinden MqttSenkronServisi sa?layan Riverpod provider.
final Provider<MqttSenkronServisi> mqttSenkronServisiProvider = Provider<MqttSenkronServisi>((Ref ref) {
  return kurHizmetBulucu<MqttSenkronServisi>();
});

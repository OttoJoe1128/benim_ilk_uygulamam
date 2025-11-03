import 'package:mqtt_client/mqtt_client.dart';

/// Nova Agro MQTT ba?lant?s? i?in yap?land?rma s?n?f?.
class MqttBaglantisi {
  final String sunucuAdresi;
  final int sunucuPortu;
  final String senkronKonu;
  final String istemciKimligi;
  final int keepAliveSaniye;
  const MqttBaglantisi({this.sunucuAdresi = 'nova-agro.local', this.sunucuPortu = 1883, this.senkronKonu = 'nova/agro/sync', this.istemciKimligi = 'nova_agro_istemci', this.keepAliveSaniye = 20});

  MqttServerClient olusturIstemci() {
    final MqttServerClient istemci = MqttServerClient(sunucuAdresi, istemciKimligi);
    istemci.keepAlivePeriod = keepAliveSaniye;
    istemci.logging(on: false);
    istemci.port = sunucuPortu;
    istemci.setProtocolV311();
    istemci.autoReconnect = true;
    istemci.onConnected = () {};
    istemci.onDisconnected = () {};
    return istemci;
  }
}

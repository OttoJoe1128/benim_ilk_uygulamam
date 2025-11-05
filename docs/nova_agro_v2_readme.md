# Nova Agro v2 - Mimarinin Genel Gorunumu

## Nova Cloud Sync 2.0
- MQTT tabanli senkronizasyon islemleri `MqttSenkronServisi` tarafindan yurutilur.
- Cevrimdisi senaryolar icin tum mesajlar `senkron_kuyruk` tablosunda saklanir.
- Riverpod uzerinden saglanan `mqttBaglantiDurumuProvider` arayuz bilesenlerinin baglanti durumu degisimlerine tepki vermesini saglar.

## Nova AI Katmani
- `OpenMeteoServisi` toprak ve hava parametrelerini cihaz uzerinde toplar.
- Her olcum `SensorSqliteDeposu` araciligiyla SQLite veritabanina kaydedilir ve `NovaAiServisi` tarafindan analiz edilir.
- `NovaAiYoneticisi` TensorFlow Lite modelinden gelen esik degerlere gore gercek zamanli oneriler uretir.
- AI ciktilari arayuzde adaptif kartlar ve ciplere donusturulur; ayni veri MQTT kuyruguna da aktarilir.

## Adaptif UI
- Kullanicinin ekranda gecirdigi sure ve tiklama yogunlugu `AdaptifTemaYoneticisi` ile izlenir.
- `adaptifUiProvider` aktif kart listesini guncelleyerek harita ekranini sade veya detayli moda tasir.
- Baglanti, sensor ve Nova AI kartlari adaptif moda gore otomatik olarak gizlenir ya da yeniden gosterilir.

## Akisin Birlesmesi
1. Harita ekraninda parsel secildiginde `OpenMeteoServisi` calisir, son veriler MQTT kuyruguna yazilir ve AI analizi tetiklenir.
2. Yeni AI karari ve sensor olcumu Riverpod saglayicilari uzerinden arayuz katmanina tasinir.
3. Adaptif yonetici aktif kartlari guncelleyerek hangi bilgilerin one cikacagini belirler.
4. Baglanti durumu degistikce kuyruga alinan mesajlar Nova Cloud Sync 2.0 ile otomatik olarak gonderilir.

Bu mimari sayesinde Nova Agro v2 tamamen cihaz uzerinde calisabilir, baglanti koptugunda verilerini kaybetmez ve kullanici davranisina uyum saglayarak arayuzu sade tutar.

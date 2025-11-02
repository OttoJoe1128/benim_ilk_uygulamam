// ignore_for_file: constant_identifier_names

/// Harita ve Mapbox yapılandırma sabitleri
/// Dikkat: Gerçek erişim anahtarını gizli tutun ve burada saklamayın.
/// Geliştirme sırasında .env ya da güvenli bir kaynaktan besleyin.
class HaritaSabitleri {
  const HaritaSabitleri._();

  /// Mapbox erişim anahtarı (placeholder). Gerçek değeri CI/CD veya
  /// çalışma zamanı gizli yönetiminden sağlayın.
  static const String MAPBOX_ACCESS_TOKEN = 'DEGIS-TIRIN:MAPBOX_ACCESS_TOKEN';

  /// Mapbox stil kimliği. Örn: 'mapbox/streets-v12' veya kullanıcıya ait özel stil
  static const String MAPBOX_STYLE_ID = 'mapbox/streets-v12';

  /// Varsayılan yakınlaşma düzeyi
  static const double VARSAYILAN_YAKINLASMA = 13.0;

  /// Harita başlangıç konumu (örnek: Ankara Kızılay)
  static const double BASLANGIC_ENLEM = 39.92077;
  static const double BASLANGIC_BOYLAM = 32.85411;

  /// Mapbox tile URL şablonu (flutter_map ile)
  static String tileUrlSablonu() {
    final String stylePath = 'styles/v1/${HaritaSabitleri.MAPBOX_STYLE_ID}';
    final String token = HaritaSabitleri.MAPBOX_ACCESS_TOKEN;
    // Retina destekli (@2x) karolar mobilde daha iyi görsellik sunar
    return 'https://api.mapbox.com/$stylePath/tiles/512/{z}/{x}/{y}@2x?access_token=$token';
  }

  /// Kullanıcıya yardımcı hata metinleri
  static String tokenUyarisi() {
    if (MAPBOX_ACCESS_TOKEN.startsWith('DEGIS-TIRIN')) {
      return 'Mapbox erişim anahtarı tanımlı değil. Lütfen HaritaSabitleri.MAPBOX_ACCESS_TOKEN değerini ayarlayın.';
    }
    return '';
  }
}

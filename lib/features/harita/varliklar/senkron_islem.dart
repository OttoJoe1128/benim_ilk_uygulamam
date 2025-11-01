import 'dart:convert';

enum SenkronIslemTuru { sensorEkle, sensorGuncelle, sensorSil, sulamaKaydet }

class SenkronIslem {
  final int? id;
  final SenkronIslemTuru tur;
  final String veri;
  final DateTime olusturmaZamani;

  const SenkronIslem({
    this.id,
    required this.tur,
    required this.veri,
    required this.olusturmaZamani,
  });

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'tur': tur.name,
      'veri': veri,
      'olusturma_zamani': olusturmaZamani.toIso8601String(),
    };
  }

  factory SenkronIslem.fromMap(Map<String, Object?> map) {
    final String turMetni = map['tur']! as String;
    return SenkronIslem(
      id: map['id'] as int?,
      tur: SenkronIslemTuru.values.firstWhere(
        (SenkronIslemTuru t) => t.name == turMetni,
      ),
      veri: map['veri']! as String,
      olusturmaZamani: DateTime.parse(map['olusturma_zamani']! as String),
    );
  }

  SenkronIslem kopyala({
    int? id,
    SenkronIslemTuru? tur,
    String? veri,
    DateTime? olusturmaZamani,
  }) {
    return SenkronIslem(
      id: id ?? this.id,
      tur: tur ?? this.tur,
      veri: veri ?? this.veri,
      olusturmaZamani: olusturmaZamani ?? this.olusturmaZamani,
    );
  }

  Map<String, Object?> veriHaritasi() {
    return json.decode(veri) as Map<String, Object?>;
  }

  static String veriToJson(Map<String, Object?> veri) => json.encode(veri);
}

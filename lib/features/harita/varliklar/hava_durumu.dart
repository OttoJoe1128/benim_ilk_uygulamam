class HavaDurumu {
  final double sicaklikC;
  final double? hissedilenSicaklikC;
  final double? ruzgarHiziMs;
  final String havaDurumuMetni;
  final DateTime guncellemeZamani;

  const HavaDurumu({
    required this.sicaklikC,
    this.hissedilenSicaklikC,
    this.ruzgarHiziMs,
    required this.havaDurumuMetni,
    required this.guncellemeZamani,
  });

  HavaDurumu kopyala({
    double? sicaklikC,
    double? hissedilenSicaklikC,
    double? ruzgarHiziMs,
    String? havaDurumuMetni,
    DateTime? guncellemeZamani,
  }) {
    return HavaDurumu(
      sicaklikC: sicaklikC ?? this.sicaklikC,
      hissedilenSicaklikC: hissedilenSicaklikC ?? this.hissedilenSicaklikC,
      ruzgarHiziMs: ruzgarHiziMs ?? this.ruzgarHiziMs,
      havaDurumuMetni: havaDurumuMetni ?? this.havaDurumuMetni,
      guncellemeZamani: guncellemeZamani ?? this.guncellemeZamani,
    );
  }
}

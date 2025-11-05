/// Sens?r verilerini temsil eden veri modeli.
class SensorOlcumu {
  final double toprakNemiYuzde;
  final double toprakSicakligiSantigrat;
  final double havaSicakligiSantigrat;
  final double isikSeviyesiLuks;
  final double bagilNemYuzde;
  final DateTime olcumZamani;
  final String kaynak;
  const SensorOlcumu({required this.toprakNemiYuzde, required this.toprakSicakligiSantigrat, required this.havaSicakligiSantigrat, required this.isikSeviyesiLuks, required this.bagilNemYuzde, required this.olcumZamani, required this.kaynak});

  Map<String, Object> haritayaDonustur() {
    return <String, Object>{
      'toprak_nemi': toprakNemiYuzde,
      'toprak_sicakligi': toprakSicakligiSantigrat,
      'hava_sicakligi': havaSicakligiSantigrat,
      'isik_seviyesi': isikSeviyesiLuks,
      'bagil_nem': bagilNemYuzde,
      'olcum_zamani': olcumZamani.millisecondsSinceEpoch,
      'kaynak': kaynak,
    };
  }

  static SensorOlcumu haritadanDonustur({required Map<String, Object?> kayit}) {
    final SensorOlcumu olcum = SensorOlcumu(
      toprakNemiYuzde: (kayit['toprak_nemi'] as num).toDouble(),
      toprakSicakligiSantigrat: (kayit['toprak_sicakligi'] as num).toDouble(),
      havaSicakligiSantigrat: (kayit['hava_sicakligi'] as num).toDouble(),
      isikSeviyesiLuks: (kayit['isik_seviyesi'] as num).toDouble(),
      bagilNemYuzde: (kayit['bagil_nem'] as num).toDouble(),
      olcumZamani: DateTime.fromMillisecondsSinceEpoch(kayit['olcum_zamani'] as int),
      kaynak: kayit['kaynak']! as String,
    );
    return olcum;
  }
}

/// Open-Meteo servisinden d?nen anl?k hava ve toprak verileri modeli.
class OpenMeteoVerisi {
  final double havaSicakligiSantigrat;
  final double bagilNemYuzde;
  final double toprakSicakligiSantigrat;
  final double toprakNemiOran;
  final double isikSeviyesiLuks;
  final DateTime olcumZamani;
  const OpenMeteoVerisi({required this.havaSicakligiSantigrat, required this.bagilNemYuzde, required this.toprakSicakligiSantigrat, required this.toprakNemiOran, required this.isikSeviyesiLuks, required this.olcumZamani});
}

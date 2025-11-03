/// Nova AI analiz sonucunu temsil eden veri modeli.
class NovaAiKarari {
  final String mesaj;
  final bool sulamaErtelensin;
  final String ikonKimligi;
  final List<String> etiketler;
  const NovaAiKarari({required this.mesaj, required this.sulamaErtelensin, required this.ikonKimligi, required this.etiketler});
}

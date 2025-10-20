sealed class TaniDurumu {
  const TaniDurumu();
}

class Baslangic extends TaniDurumu {
  const Baslangic();
}

class Yukleniyor extends TaniDurumu {
  const Yukleniyor();
}

class Basari extends TaniDurumu {
  final List<String> etiketler;
  const Basari({required this.etiketler});
}

class Hata extends TaniDurumu {
  final String mesaj;
  const Hata({required this.mesaj});
}

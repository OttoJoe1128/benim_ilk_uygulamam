import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/varliklar/mesaj.dart';

part 'sohbet_durumu.freezed.dart';

@freezed
class SohbetDurumu with _$SohbetDurumu {
  const factory SohbetDurumu.yukleniyor() = _Yukleniyor;
  const factory SohbetDurumu.basarisiz(String mesaj) = _Basarisiz;
  const factory SohbetDurumu.basarili(List<Mesaj> mesajlar) = _Basarili;
}

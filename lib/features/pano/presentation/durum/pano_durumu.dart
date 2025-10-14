import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/varliklar/pano.dart';

part 'pano_durumu.freezed.dart';

@freezed
class PanoDurumu with _$PanoDurumu {
  const factory PanoDurumu.yukleniyor() = _Yukleniyor;
  const factory PanoDurumu.basarisiz(String mesaj) = _Basarisiz;
  const factory PanoDurumu.basarili(List<Pano> panolar) = _Basarili;
}

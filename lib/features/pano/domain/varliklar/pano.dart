import 'package:freezed_annotation/freezed_annotation.dart';

part 'pano.freezed.dart';
part 'pano.g.dart';

@freezed
class Pano with _$Pano {
  const factory Pano({required String id, required String baslik, required DateTime olusturulma, required DateTime bitis}) = _Pano;
  factory Pano.fromJson(Map<String, dynamic> json) => _$PanoFromJson(json);
}

extension PanoUzantilari on Pano {
  bool isSuresiDoldu() {
    return DateTime.now().isAfter(bitis);
  }
}

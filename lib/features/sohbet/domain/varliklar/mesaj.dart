import 'package:freezed_annotation/freezed_annotation.dart';

part 'mesaj.freezed.dart';
part 'mesaj.g.dart';

@freezed
class Mesaj with _$Mesaj {
  const factory Mesaj({required String id, required String panoId, required String icerik, required DateTime zaman}) = _Mesaj;
  factory Mesaj.fromJson(Map<String, dynamic> json) => _$MesajFromJson(json);
}

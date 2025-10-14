import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:benim_ilk_uygulamam/features/pano/data/depolar/pano_deposu_bellek.dart';
import 'package:benim_ilk_uygulamam/features/pano/domain/sozlesmeler/pano_deposu.dart';

void main() {
  test('Pano süresi dolunca listeden kalkar', () async {
    final PanoDeposuBellek depo = PanoDeposuBellek(uuid: const Uuid());
    final DateTime bitis = DateTime.now().add(const Duration(milliseconds: 10));
    await depo.olusturPano(PanoGirdi(baslik: 'Geçici', bitis: bitis));
    expect((await depo.getirPanolari()).length, 1);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect((await depo.getirPanolari()).length, 0);
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../domain/sozlesmeler/pano_deposu.dart';
import '../../domain/varliklar/pano.dart';

class PanoDeposuFirestore implements PanoDeposu {
  final FirebaseFirestore firestore;
  final Uuid uuidUretici;
  PanoDeposuFirestore({required this.firestore, required this.uuidUretici});

  @override
  Future<List<PanoCikti>> getirPanolari() async {
    final QuerySnapshot<Map<String, dynamic>> sn = await firestore
        .collection('panolar')
        .where('bitis', isGreaterThan: DateTime.now())
        .orderBy('bitis')
        .get();
    return sn.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) {
          final Map<String, dynamic> j = d.data();
          return PanoCikti(
            id: d.id,
            baslik: j['baslik'] as String,
            olusturulma: (j['olusturulma'] as Timestamp).toDate(),
            bitis: (j['bitis'] as Timestamp).toDate(),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<PanoCikti> olusturPano(PanoGirdi girdi) async {
    final QuerySnapshot<Map<String, dynamic>> ayniBaslik = await firestore
        .collection('panolar')
        .where('baslik', isEqualTo: girdi.baslik)
        .where('bitis', isGreaterThan: DateTime.now())
        .limit(1)
        .get();
    if (ayniBaslik.docs.isNotEmpty) {
      throw Exception('Aynı başlığa sahip aktif pano zaten var');
    }
    final String yeniId = uuidUretici.v4();
    final Map<String, dynamic> veri = <String, dynamic>{
      'baslik': girdi.baslik,
      'olusturulma': Timestamp.fromDate(DateTime.now()),
      'bitis': Timestamp.fromDate(girdi.bitis),
    };
    await firestore.collection('panolar').doc(yeniId).set(veri);
    return PanoCikti(id: yeniId, baslik: girdi.baslik, olusturulma: DateTime.now(), bitis: girdi.bitis);
  }

  @override
  Future<void> silPano(String panoId) async {
    await firestore.collection('panolar').doc(panoId).delete();
  }
}

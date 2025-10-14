import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../domain/sozlesmeler/sohbet_deposu.dart';
import '../../domain/varliklar/mesaj.dart';

class SohbetDeposuFirestore implements SohbetDeposu {
  final FirebaseFirestore firestore;
  final Uuid uuidUretici;
  SohbetDeposuFirestore({required this.firestore, required this.uuidUretici});

  @override
  Future<List<MesajCikti>> getirMesajlar(String panoId) async {
    final QuerySnapshot<Map<String, dynamic>> sn = await firestore
        .collection('panolar')
        .doc(panoId)
        .collection('mesajlar')
        .orderBy('zaman', descending: true)
        .limit(200)
        .get();
    return sn.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) {
          final Map<String, dynamic> j = d.data();
          return MesajCikti(
            id: d.id,
            panoId: panoId,
            icerik: j['icerik'] as String,
            zaman: (j['zaman'] as Timestamp).toDate(),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<MesajCikti> ekleMesaj(MesajGirdi girdi) async {
    final String yeniId = uuidUretici.v4();
    final Map<String, dynamic> veri = <String, dynamic>{
      'icerik': girdi.icerik,
      'zaman': Timestamp.fromDate(DateTime.now()),
    };
    await firestore
        .collection('panolar')
        .doc(girdi.panoId)
        .collection('mesajlar')
        .doc(yeniId)
        .set(veri);
    return MesajCikti(id: yeniId, panoId: girdi.panoId, icerik: girdi.icerik, zaman: DateTime.now());
  }

  @override
  Future<void> silMesaj(String mesajId) async {
    // PanoId bilinmeden silmek için: koleksiyon grubu sorguları gerekir.
    throw UnimplementedError('Mesaj silme için panoId gerekli kılınmalıdır.');
  }
}

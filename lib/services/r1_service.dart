import 'package:cloud_firestore/cloud_firestore.dart';

class R1Service {
  static final R1Service _i = R1Service._();
  R1Service._();
  factory R1Service() => _i;

  // Validates that the text contains 1–2 occurrences of "{blank}".
  bool isTemplateValid(String text) => _countBlanks(text) >= 1 && _countBlanks(text) <= 2;
  int _countBlanks(String text) => "{blank}".allMatches(text).length;

  Future<void> submitSentences({required String code, required String uid, required String s1, required String s2}) async {
    if (!isTemplateValid(s1) || !isTemplateValid(s2)) {
      throw ArgumentError('Each sentence must include 1–2 {blank} tokens.');
    }
    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('rooms').doc(code);
    final batch = db.batch();
    final now = FieldValue.serverTimestamp();

    final col = roomRef.collection('r1_sentences');
    final doc1 = col.doc();
    final doc2 = col.doc();
    batch.set(doc1, {'authorUid': uid, 'textTemplate': s1.trim(), 'blanksCount': _countBlanks(s1), 'createdAt': now});
    batch.set(doc2, {'authorUid': uid, 'textTemplate': s2.trim(), 'blanksCount': _countBlanks(s2), 'createdAt': now});

    await batch.commit();
  }
}

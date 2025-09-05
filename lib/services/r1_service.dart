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

  // Replaces {blank} tokens left-to-right with provided values.
  String buildFilledText(String template, List<String> values) {
    final parts = template.split('{blank}');
    if (parts.length - 1 == 0) return template; // no blanks
    final sb = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      sb.write(parts[i]);
      if (i < parts.length - 1) {
        final v = (i < values.length) ? values[i] : '';
        sb.write(v);
      }
    }
    return sb.toString();
  }

  Future<void> submitFill({required String code, required String uid, required String baseSentenceId, required List<String> values}) async {
    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('rooms').doc(code);
    final fills = roomRef.collection('r1_fills');
    await fills.add({'baseSentenceId': baseSentenceId, 'fillerUid': uid, 'values': values, 'createdAt': FieldValue.serverTimestamp()});
  }

  // Assignment model: map playerUid -> baseSentenceId
  Map<String, String> computeFillAssignments({required List<String> playerUids, required Map<String, String> sentenceAuthors, required List<String> sentenceIds}) {
    // sentenceAuthors: sentenceId -> authorUid
    // Goal: each player gets one sentence not authored by them; two players share same sentence.
    final result = <String, String>{};
    if (playerUids.isEmpty || sentenceIds.isEmpty) return result;

    // Deterministic: sort inputs
    final players = [...playerUids]..sort();
    final sIds = [...sentenceIds];
    sIds.sort();

    int si = 0;
    for (var i = 0; i < players.length; i += 2) {
      final a = players[i];
      final b = (i + 1 < players.length) ? players[i + 1] : null;
      // Find a sentence neither authored; wrap if needed
      for (var attempt = 0; attempt < sIds.length; attempt++) {
        final sId = sIds[si % sIds.length];
        final author = sentenceAuthors[sId];
        si++;
        if (author != a && (b == null || author != b)) {
          result[a] = sId;
          if (b != null) result[b] = sId; // both fill same sentence
          break;
        }
      }
    }
    return result;
  }

  Future<void> buildAssignmentsForRoom(String code) async {
    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('rooms').doc(code);
    final playersSnap = await roomRef.collection('players').get();
    final sentencesSnap = await roomRef.collection('r1_sentences').get();
    if (playersSnap.docs.isEmpty || sentencesSnap.docs.isEmpty) return;

    final players = playersSnap.docs.map((d) => d.id).toList()..sort();
    final sentenceIds = sentencesSnap.docs.map((d) => d.id).toList()..sort();
    final sentenceAuthors = {for (final d in sentencesSnap.docs) d.id: (d.data()['authorUid'] as String? ?? '')};

    final assignments = computeFillAssignments(playerUids: players, sentenceAuthors: sentenceAuthors, sentenceIds: sentenceIds);
    final batch = db.batch();
    final col = roomRef.collection('r1_assignments');
    assignments.forEach((uid, sId) {
      batch.set(col.doc(uid), {'baseSentenceId': sId, 'createdAt': FieldValue.serverTimestamp()});
    });
    await batch.commit();
  }
}

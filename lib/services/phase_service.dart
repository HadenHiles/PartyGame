import 'package:cloud_firestore/cloud_firestore.dart';

class PhaseService {
  static final PhaseService _i = PhaseService._();
  PhaseService._();
  factory PhaseService() => _i;

  Stream<bool> allPlayersDone(String code, {required String progressKey}) {
    try {
      final db = FirebaseFirestore.instance;
      final playersCol = db.collection('rooms').doc(code).collection('players');
      return playersCol.snapshots().map((qs) {
        if (qs.docs.isEmpty) return false;
        for (final d in qs.docs) {
          final p = d.data();
          final progress = p['progress'] as Map<String, dynamic>?;
          if (progress == null || progress[progressKey] != true) return false;
        }
        return true;
      });
    } catch (_) {
      // In tests or environments where Firebase isn't initialized, emit false.
      return Stream<bool>.value(false);
    }
  }

  Future<void> advancePhase(String code, {required String nextPhase}) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('rooms').doc(code).set({'phase': nextPhase, 'phaseStartAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (_) {
      // Swallow in tests where Firebase isn't initialized.
    }
  }
}

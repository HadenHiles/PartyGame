import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/services/firebase_service.dart';

void main() {
  test('FirebaseService uid is null when not initialized (safe getter)', () {
    // In test env without Firebase.initializeApp, uid should safely be null.
    final uid = FirebaseService().uid;
    expect(uid, isNull);
  });
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Placeholder for Firebase initialization once flutterfire config is added.
/// After you run `flutterfire configure`, add the generated firebase_options.dart
/// and call `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
/// from your app bootstrap. For now, we provide a no-op guard to keep code compiling.
class FirebaseService {
  static final FirebaseService _i = FirebaseService._();
  FirebaseService._();
  factory FirebaseService() => _i;

  bool _initialized = false;
  bool get isInitialized => _initialized;
  String? get uid {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      // No default app in test or init not completed yet
      return null;
    }
  }

  Future<void> initIfNeeded() async {
    if (_initialized) return;
    // In case this is called before main() initializes Firebase (e.g., tests),
    // we keep this lightweight. Auth sign-in will fail safely if Firebase isn't ready yet.
    try {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('FirebaseService: signed in anonymously as ${FirebaseAuth.instance.currentUser?.uid}');
    } catch (e) {
      debugPrint('FirebaseService: anonymous sign-in skipped ($e)');
    }
    _initialized = true;
  }
}

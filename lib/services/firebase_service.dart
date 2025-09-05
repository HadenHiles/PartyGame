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

  Future<void> initIfNeeded() async {
    if (_initialized) return;
    // Will be replaced with real Firebase init once options are present.
    debugPrint('FirebaseService: waiting for flutterfire config.');
    _initialized = true; // keep app flow unblocked during scaffolding
  }
}

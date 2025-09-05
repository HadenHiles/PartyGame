import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/room_service.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseService().initIfNeeded();
  // Prefer Firestore-backed service now that Firebase is ready
  RoomService.use(FirestoreRoomService());
  runApp(const PartyGameApp());
}

class PartyGameApp extends StatelessWidget {
  const PartyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Party Game', theme: AppTheme.light(), routerConfig: appRouter, debugShowCheckedModeBanner: false);
  }
}

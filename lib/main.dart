import 'package:flutter/material.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PartyGameApp());
}

class PartyGameApp extends StatelessWidget {
  const PartyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Party Game', theme: AppTheme.light(), routerConfig: appRouter, debugShowCheckedModeBanner: false);
  }
}

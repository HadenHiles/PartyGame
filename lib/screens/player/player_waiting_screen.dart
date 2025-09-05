import 'package:flutter/material.dart';

class PlayerWaitingScreen extends StatelessWidget {
  final String code;
  const PlayerWaitingScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting Room')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Waiting for host to start...'),
            const SizedBox(height: 12),
            Text('Room: $code', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

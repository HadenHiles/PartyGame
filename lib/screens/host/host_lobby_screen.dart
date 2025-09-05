import 'package:flutter/material.dart';

class HostLobbyScreen extends StatelessWidget {
  final String code;
  const HostLobbyScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Lobby')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Room Code', style: TextStyle(fontSize: 18)),
            Text(code, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Start Round 1')),
          ],
        ),
      ),
    );
  }
}

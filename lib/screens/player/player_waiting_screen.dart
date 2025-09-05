import 'package:flutter/material.dart';
import '../../services/room_service.dart';
import '../../models/player.dart';

class PlayerWaitingScreen extends StatelessWidget {
  final String code;
  const PlayerWaitingScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting Room')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Room: $code', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder(
              stream: RoomService().roomStream(code),
              builder: (context, snapshot) {
                final phase = snapshot.data?.phase ?? 'lobby';
                return Text('Waiting for host to start... (phase: $phase)');
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<Player>>(
                stream: RoomService().playersStream(code),
                builder: (context, snapshot) {
                  final players = snapshot.data ?? const <Player>[];
                  if (players.isEmpty) {
                    return const Center(child: Text('No players yet'));
                  }
                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final p = players[index];
                      return ListTile(leading: const Icon(Icons.person_outline), title: Text(p.displayName), subtitle: Text(p.uid.substring(0, 6)));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

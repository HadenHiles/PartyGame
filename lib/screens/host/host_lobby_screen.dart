import 'package:flutter/material.dart';
import '../../services/room_service.dart';
import '../../models/player.dart';

class HostLobbyScreen extends StatelessWidget {
  final String code;
  const HostLobbyScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Lobby')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Room Code', style: TextStyle(fontSize: 18)),
            Text(code, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: RoomService().roomStream(code),
              builder: (context, snapshot) {
                final room = snapshot.data;
                final phase = room?.phase ?? 'lobby';
                final status = room?.status ?? 'open';
                return Text('Status: $status • Phase: $phase');
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<Player>>(
                stream: RoomService().playersStream(code),
                builder: (context, snapshot) {
                  final players = snapshot.data ?? const <Player>[];
                  if (players.isEmpty) {
                    return const Center(child: Text('Waiting for players…'));
                  }
                  return ListView.separated(
                    itemCount: players.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = players[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?')),
                        title: Text(p.displayName),
                        subtitle: Text(p.uid.substring(0, 6)),
                        trailing: p.isHost ? const Icon(Icons.star, color: Colors.amber) : null,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await RoomService().startGame(code);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game started: Round 1 - Author phase')));
              },
              child: const Text('Start Round 1'),
            ),
          ],
        ),
      ),
    );
  }
}

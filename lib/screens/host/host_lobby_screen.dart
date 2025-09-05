import 'package:flutter/material.dart';
import '../../services/room_service.dart';
import '../../models/player.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/neon_background.dart';
import '../../widgets/confetti_overlay.dart';

class HostLobbyScreen extends StatefulWidget {
  final String code;
  const HostLobbyScreen({super.key, required this.code});

  @override
  State<HostLobbyScreen> createState() => _HostLobbyScreenState();
}

class _HostLobbyScreenState extends State<HostLobbyScreen> {
  final confettiKey = GlobalKey<ConfettiOverlayState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Lobby 🎛️')),
      body: Stack(
        children: [
          const NeonAnimatedBackground(),
          ConfettiOverlay(key: confettiKey),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('ROOM CODE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.inversePrimary, borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(widget.code, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: RoomService().roomStream(widget.code),
                  builder: (context, snapshot) {
                    final room = snapshot.data;
                    final phase = room?.phase ?? 'lobby';
                    final status = room?.status ?? 'open';
                    if (phase == 'author') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;
                        context.go('/host/round/${widget.code}');
                      });
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('Status: $status • Phase: $phase', style: const TextStyle(fontWeight: FontWeight.w800)),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: StreamBuilder<List<Player>>(
                    stream: RoomService().playersStream(widget.code),
                    builder: (context, snapshot) {
                      final players = snapshot.data ?? const <Player>[];
                      if (players.isEmpty) {
                        return const Center(
                          child: Text('Waiting for players…', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        );
                      }
                      return ListView.separated(
                        itemCount: players.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = players[index];
                          final idShort = p.uid.length >= 6 ? p.uid.substring(0, 6) : p.uid;
                          return ListTile(
                            leading: CircleAvatar(child: Text(p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?')),
                            title: Text(p.displayName),
                            subtitle: Text(idShort),
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
                    await RoomService().startGame(widget.code);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game started: Round 1 - Author phase')));
                    confettiKey.currentState?.burst();
                  },
                  child: const Text('START ROUND 1'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

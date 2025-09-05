import 'package:flutter/material.dart';
import '../../services/room_service.dart';
import '../../models/player.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/neon_background.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerWaitingScreen extends StatelessWidget {
  final String code;
  const PlayerWaitingScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting Room ⏳')),
      body: Stack(
        children: [
          const NeonAnimatedBackground(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(14)),
                  child: Text('Room: $code', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 12),
                StreamBuilder(
                  stream: RoomService().roomStream(code),
                  builder: (context, snapshot) {
                    final phase = snapshot.data?.phase ?? 'lobby';
                    if (phase == 'author') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;
                        context.go('/r1/author/$code');
                      });
                    } else if (phase == 'fill') {
                      // If fill phase begins and player has an assignment, route to fill
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (!context.mounted) return;
                        final uid = FirebaseService().uid;
                        if (uid == null) return;
                        final db = FirebaseFirestore.instance;
                        final asn = await db.collection('rooms').doc(code).collection('r1_assignments').doc(uid).get();
                        if (!asn.exists) return;
                        final baseId = asn.data()?['baseSentenceId'] as String?;
                        if (baseId == null) return;
                        final sent = await db.collection('rooms').doc(code).collection('r1_sentences').doc(baseId).get();
                        final tmpl = sent.data()?['textTemplate'] as String?;
                        if (tmpl == null) return;
                        if (!context.mounted) return;
                        context.go('/r1/fill/$code?id=$baseId&t=${Uri.encodeComponent(tmpl)}');
                      });
                    }
                    return Text('Waiting for host to start... (phase: $phase)', style: const TextStyle(fontWeight: FontWeight.w800));
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
                          final idShort = p.uid.length >= 6 ? p.uid.substring(0, 6) : p.uid;
                          return ListTile(leading: const Icon(Icons.person_outline), title: Text(p.displayName), subtitle: Text(idShort));
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Developer shortcut: navigate to assigned fill
                ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final router = GoRouter.of(context);
                    final uid = FirebaseService().uid;
                    if (uid == null) {
                      messenger.showSnackBar(const SnackBar(content: Text('Not signed in.')));
                      return;
                    }
                    try {
                      final db = FirebaseFirestore.instance;
                      final asn = await db.collection('rooms').doc(code).collection('r1_assignments').doc(uid).get();
                      if (!asn.exists) {
                        messenger.showSnackBar(const SnackBar(content: Text('No assignment yet.')));
                        return;
                      }
                      final baseId = asn.data()?['baseSentenceId'] as String?;
                      if (baseId == null) {
                        messenger.showSnackBar(const SnackBar(content: Text('Assignment malformed.')));
                        return;
                      }
                      final sent = await db.collection('rooms').doc(code).collection('r1_sentences').doc(baseId).get();
                      final tmpl = sent.data()?['textTemplate'] as String?;
                      if (tmpl == null) {
                        messenger.showSnackBar(const SnackBar(content: Text('Sentence missing.')));
                        return;
                      }
                      router.go('/r1/fill/$code?id=$baseId&t=${Uri.encodeComponent(tmpl)}');
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Go to my Fill (DEV)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

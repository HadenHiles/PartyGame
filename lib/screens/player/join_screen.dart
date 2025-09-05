import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
import '../../widgets/neon_background.dart';
import '../../services/room_service.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join the Party 🎉')),
      body: Stack(
        children: [
          const NeonAnimatedBackground(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('PartyGames', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Theme.of(context).colorScheme.inversePrimary)),
                const SizedBox(height: 24),
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        if (FirebaseService().uid != null) Text('Signed in: ${FirebaseService().uid!.substring(0, 6)}…', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Your display name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _codeCtrl,
                          decoration: const InputDecoration(labelText: 'Room code (e.g. W4V3Z)'),
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (_codeCtrl.text.trim().isEmpty) return;
                            final code = _codeCtrl.text.trim().toUpperCase();
                            final uid = FirebaseService().uid ?? 'anon';
                            final displayName = _nameCtrl.text.trim().isEmpty ? 'Player' : _nameCtrl.text.trim();
                            try {
                              await RoomService().joinRoom(code: code, uid: uid, displayName: displayName);
                              if (!context.mounted) return;
                              context.go('/wait/$code');
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to join: ${e is StateError ? e.message : e.toString()}')));
                            }
                          },
                          child: const Text('LET’S GO'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    // For quick host testing: create a room then navigate
                    final uid = FirebaseService().uid ?? 'anon';
                    final displayName = _nameCtrl.text.trim().isEmpty ? 'Host' : _nameCtrl.text.trim();
                    final code = await RoomService().createRoom(hostUid: uid, hostDisplayName: displayName);
                    if (!context.mounted) return;
                    context.go('/host/$code');
                  },
                  child: const Text('Host a game (dev)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

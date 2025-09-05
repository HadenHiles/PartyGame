import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
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
      appBar: AppBar(title: const Text('Join Game')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (FirebaseService().uid != null) Text('You are signed in as: ${FirebaseService().uid!.substring(0, 6)}…', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(labelText: 'Room code'),
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
              child: const Text('Join'),
            ),
            const SizedBox(height: 24),
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
    );
  }
}

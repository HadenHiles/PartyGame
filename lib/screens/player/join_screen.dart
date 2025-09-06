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
  bool _joining = false;
  bool _hosting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final raw = _codeCtrl.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a room code.')));
      return;
    }
    final code = raw.toUpperCase();
    final uid = FirebaseService().uid ?? 'anon';
    final displayName = _nameCtrl.text.trim().isEmpty ? 'Player' : _nameCtrl.text.trim();
    setState(() => _joining = true);
    try {
      await RoomService().joinRoom(code: code, uid: uid, displayName: displayName);
      if (!mounted) return;
      context.go('/wait/$code');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to join: ${e is StateError ? e.message : e.toString()}')));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _handleHost() async {
    final uid = FirebaseService().uid ?? 'anon';
    final displayName = _nameCtrl.text.trim().isEmpty ? 'Host' : _nameCtrl.text.trim();
    setState(() => _hosting = true);
    try {
      final code = await RoomService().createRoom(hostUid: uid, hostDisplayName: displayName);
      if (!mounted) return;
      context.go('/host/$code');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to host: $e')));
    } finally {
      if (mounted) setState(() => _hosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _joining || _hosting;
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
                          enabled: !busy,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _codeCtrl,
                          decoration: const InputDecoration(labelText: 'Room code (e.g. W4V3Z)'),
                          textCapitalization: TextCapitalization.characters,
                          enabled: !_hosting, // allow editing while not hosting
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: busy ? null : _handleHost,
                                child: _hosting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('HOST GAME'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: busy ? null : _handleJoin,
                                child: _joining ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('JOIN GAME'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Enter a code to join or host a fresh room.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

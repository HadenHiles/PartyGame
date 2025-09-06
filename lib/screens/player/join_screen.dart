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

enum _EntryMode { select, host, join }

class _JoinScreenState extends State<JoinScreen> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _joining = false;
  bool _hosting = false;
  _EntryMode _mode = _EntryMode.select;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _goBackToSelect() {
    setState(() {
      _mode = _EntryMode.select;
      _joining = false;
      _hosting = false;
    });
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

  Widget _buildSelectCard(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How do you want to start?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _mode = _EntryMode.host),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                child: const Text('HOST A GAME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _mode = _EntryMode.join),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                child: const Text('JOIN A GAME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Hosting will generate a new room code automatically.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHostForm(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(onPressed: _hosting ? null : _goBackToSelect, icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 4),
                const Text('Host a Game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Display name (optional)'),
              enabled: !_hosting,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _hosting ? null : _handleHost,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _hosting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('CREATE ROOM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            const Text('We will generate a 5‑character code for players to join.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinForm(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(onPressed: _joining ? null : _goBackToSelect, icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 4),
                const Text('Join a Game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Display name (optional)'),
              enabled: !_joining,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(labelText: 'Room code'),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              enabled: !_joining,
              onSubmitted: (_) => _joining ? null : _handleJoin(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _joining ? null : _handleJoin,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _joining ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('JOIN ROOM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            const Text('Ask the host for the 5‑character code.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PartyGames 🎉')),
      body: Stack(
        children: [
          const NeonAnimatedBackground(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: () {
                    switch (_mode) {
                      case _EntryMode.select:
                        return _buildSelectCard(context);
                      case _EntryMode.host:
                        return _buildHostForm(context);
                      case _EntryMode.join:
                        return _buildJoinForm(context);
                    }
                  }(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              onPressed: () {
                if (_codeCtrl.text.trim().isEmpty) return;
                final code = _codeCtrl.text.trim().toUpperCase();
                context.go('/wait/$code');
              },
              child: const Text('Join'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                // For quick host testing
                context.go('/host/ABCD');
              },
              child: const Text('Host a game (dev)'),
            ),
          ],
        ),
      ),
    );
  }
}

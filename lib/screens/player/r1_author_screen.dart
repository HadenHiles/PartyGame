import 'package:flutter/material.dart';
import '../../widgets/neon_background.dart';
import '../../widgets/confetti_overlay.dart';
import '../../services/r1_service.dart';
import '../../services/firebase_service.dart';

class R1AuthorScreen extends StatefulWidget {
  final String code;
  const R1AuthorScreen({super.key, required this.code});

  @override
  State<R1AuthorScreen> createState() => _R1AuthorScreenState();
}

class _R1AuthorScreenState extends State<R1AuthorScreen> {
  final s1Ctrl = TextEditingController();
  final s2Ctrl = TextEditingController();
  final confettiKey = GlobalKey<ConfettiOverlayState>();
  bool _submitting = false;

  @override
  void dispose() {
    s1Ctrl.dispose();
    s2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Round 1 – Author ✍️')),
      body: Stack(
        children: [
          const NeonAnimatedBackground(),
          ConfettiOverlay(key: confettiKey),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Make it spicy and silly!', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Write 2 sentences with 1–2 {blank} tokens each.'),
                        const SizedBox(height: 12),
                        TextField(
                          controller: s1Ctrl,
                          decoration: const InputDecoration(labelText: 'Sentence 1 e.g. I love {blank} on {blank} nights'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: s2Ctrl,
                          decoration: const InputDecoration(labelText: 'Sentence 2 e.g. My {blank} can outdance your {blank}'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          final s1 = s1Ctrl.text.trim();
                          final s2 = s2Ctrl.text.trim();
                          final messenger = ScaffoldMessenger.of(context);
                          final uid = FirebaseService().uid;
                          if (uid == null) {
                            messenger.showSnackBar(const SnackBar(content: Text('Not signed in. Try again.')));
                            return;
                          }
                          if (!R1Service().isTemplateValid(s1) || !R1Service().isTemplateValid(s2)) {
                            messenger.showSnackBar(const SnackBar(content: Text('Each sentence must include 1–2 {blank} tokens.')));
                            return;
                          }
                          setState(() => _submitting = true);
                          try {
                            await R1Service().submitSentences(code: widget.code, uid: uid, s1: s1, s2: s2);
                            if (!mounted) return;
                            confettiKey.currentState?.burst();
                            messenger.showSnackBar(const SnackBar(content: Text('Sentences submitted!')));
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(SnackBar(content: Text('Submit failed: $e')));
                          } finally {
                            if (mounted) setState(() => _submitting = false);
                          }
                        },
                  child: Text(_submitting ? 'Submitting…' : 'SUBMIT SENTENCES'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

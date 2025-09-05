import 'package:flutter/material.dart';
import '../../widgets/neon_background.dart';
import '../../widgets/confetti_overlay.dart';

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
                  onPressed: () {
                    // TODO: Validate and submit sentences to Firestore
                    confettiKey.currentState?.burst();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sentences submitted!')));
                  },
                  child: const Text('SUBMIT SENTENCES'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

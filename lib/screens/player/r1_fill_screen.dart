import 'package:flutter/material.dart';
import '../../widgets/neon_background.dart';
import '../../widgets/confetti_overlay.dart';
import '../../services/firebase_service.dart';
import '../../services/r1_service.dart';

class R1FillScreen extends StatefulWidget {
  final String code;
  final String baseSentenceId;
  final String textTemplate;
  const R1FillScreen({super.key, required this.code, required this.baseSentenceId, required this.textTemplate});

  @override
  State<R1FillScreen> createState() => _R1FillScreenState();
}

class _R1FillScreenState extends State<R1FillScreen> {
  final confettiKey = GlobalKey<ConfettiOverlayState>();
  final val1Ctrl = TextEditingController();
  final val2Ctrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    val1Ctrl.dispose();
    val2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blanks = "{blank}".allMatches(widget.textTemplate).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Round 1 – Fill ✍️')),
      body: Stack(
        children: [
          const NeonAnimatedBackground(),
          ConfettiOverlay(key: confettiKey),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Fill the blanks', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Base sentence:'),
                        const SizedBox(height: 8),
                        Text(widget.textTemplate, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (blanks >= 1)
                          TextField(
                            controller: val1Ctrl,
                            decoration: const InputDecoration(labelText: 'Fill 1'),
                          ),
                        if (blanks >= 2) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: val2Ctrl,
                            decoration: const InputDecoration(labelText: 'Fill 2'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final uid = FirebaseService().uid;
                          if (uid == null) {
                            messenger.showSnackBar(const SnackBar(content: Text('Not signed in. Try again.')));
                            return;
                          }
                          final values = <String>[];
                          if (blanks >= 1) values.add(val1Ctrl.text.trim());
                          if (blanks >= 2) values.add(val2Ctrl.text.trim());
                          if (values.any((v) => v.isEmpty)) {
                            messenger.showSnackBar(const SnackBar(content: Text('Please fill all blanks.')));
                            return;
                          }
                          setState(() => _submitting = true);
                          try {
                            await R1Service().submitFill(code: widget.code, uid: uid, baseSentenceId: widget.baseSentenceId, values: values);
                            if (!mounted) return;
                            confettiKey.currentState?.burst();
                            messenger.showSnackBar(const SnackBar(content: Text('Fill submitted!')));
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(SnackBar(content: Text('Submit failed: $e')));
                          } finally {
                            if (mounted) setState(() => _submitting = false);
                          }
                        },
                  child: Text(_submitting ? 'Submitting…' : 'SUBMIT FILL'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

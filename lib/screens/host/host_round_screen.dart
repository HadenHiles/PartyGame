import 'package:flutter/material.dart';
import '../../widgets/neon_background.dart';
import '../../services/r1_service.dart';

class HostRoundScreen extends StatelessWidget {
  final String code;
  const HostRoundScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Round 1 – Author ✍️')),
      body: Stack(
        children: [
          const NeonAnimatedBackground(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.inversePrimary, borderRadius: BorderRadius.circular(18)),
                  child: Text('Room: $code', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 16),
                Text('Author your best prompts!', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 12),
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Players are writing 2 sentences with 1–2 {blank} tokens.'), SizedBox(height: 8), Text('When time is up, we’ll move to the fill phase!')]),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await R1Service().buildAssignmentsForRoom(code);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill assignments built for players.')));
                  },
                  child: const Text('BUILD FILL ASSIGNMENTS'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: () {}, child: const Text('ADVANCE PHASE')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

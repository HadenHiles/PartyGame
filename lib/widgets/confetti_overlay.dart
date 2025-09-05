import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// Reusable confetti overlay that can be placed at the top of a Stack.
/// Use [ConfettiOverlayState.burst] to fire a quick celebration.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fire a short one-shot burst.
  void burst() {
    if (mounted) {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _controller,
          shouldLoop: false,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 30,
          gravity: 0.25,
          emissionFrequency: 0.0,
          minBlastForce: 4,
          maxBlastForce: 12,
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.tertiary],
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class NeonAnimatedBackground extends StatefulWidget {
  const NeonAnimatedBackground({super.key});

  @override
  State<NeonAnimatedBackground> createState() => _NeonAnimatedBackgroundState();
}

class _NeonAnimatedBackgroundState extends State<NeonAnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value * 2 * math.pi;
          final c1 = Alignment(math.sin(t) * 0.8, math.cos(t) * 0.8);
          final c2 = Alignment(math.sin(t + 2) * 0.8, math.cos(t + 2) * 0.8);
          final c3 = Alignment(math.sin(t + 4) * 0.8, math.cos(t + 4) * 0.8);
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(center: c1, radius: 1.2, colors: [scheme.primary.withValues(alpha: 0.22), Colors.transparent], stops: const [0.0, 1.0]),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(center: c2, radius: 1.2, colors: [scheme.secondary.withValues(alpha: 0.22), Colors.transparent], stops: const [0.0, 1.0]),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(center: c3, radius: 1.2, colors: [scheme.inversePrimary.withValues(alpha: 0.18), Colors.transparent], stops: const [0.0, 1.0]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

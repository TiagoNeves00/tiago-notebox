import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernFab extends StatefulWidget {
  final VoidCallback onCreate;
  const ModernFab({super.key, required this.onCreate});

  @override
  State<ModernFab> createState() => _S();
}

class _S extends State<ModernFab> with TickerProviderStateMixin {
  // Continuous animation for gradient rotation and glow
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  bool down = false;

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const c1 = Color(0xFFEA00FF);
    const c2 = Color.fromARGB(172, 95, 2, 38);

    return AnimatedScale(
      scale: down ? .94 : 1,
      duration: const Duration(milliseconds: 110),
      child: GestureDetector(
        onTapDown: (_) => setState(() => down = true),
        onTapCancel: () => setState(() => down = false),
        onTapUp: (_) {
          setState(() => down = false);
          HapticFeedback.lightImpact();
          widget.onCreate();
        },
        child: AnimatedBuilder(
          animation: _loop,
          builder: (context, _) {
            final angle = _loop.value * 2 * math.pi;
            final pulse = (math.sin(angle) + 1) / 2; // 0..1
            final ringAlpha = 0.55 + 0.45 * pulse; // fade ring only

            final outerGlow1 = BoxShadow(
              color: c1.withValues(alpha: (0.15 + 0.15 * pulse)),
              blurRadius: 20 + 28 * pulse,
              spreadRadius: 1 + 3 * pulse,
            );
            final outerGlow2 = BoxShadow(
              color: c2.withValues(alpha: (0.10 + 0.10 * (1 - pulse))),
              blurRadius: 14 + 24 * (1 - pulse),
              spreadRadius: 1 + 2 * (1 - pulse),
            );

            const ringThickness = 3.0;
            const size = 72.0;
            final innerSize = size - ringThickness * 2;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Soft colored glow halo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [outerGlow1, outerGlow2],
                  ),
                ),
                // Rotating/fading gradient BORDER
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        c1.withValues(alpha: ringAlpha),
                        c2.withValues(alpha: ringAlpha),
                        c1.withValues(alpha: ringAlpha),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                      transform: GradientRotation(angle),
                    ),
                  ),
                ),
                // Solid pink base fill to show only a gradient ring
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: c1,
                  ),
                ),
                // Icon with a subtle tilt on press
                AnimatedRotation(
                  turns: down ? .125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 48),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
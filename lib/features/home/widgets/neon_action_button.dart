import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NeonActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const NeonActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.borderRadius = 12,
  });

  @override
  State<NeonActionButton> createState() => _NeonActionButtonState();
}

class _NeonActionButtonState extends State<NeonActionButton>
    with TickerProviderStateMixin {
  static const Color _c1 = Color(0xFFEA00FF);
  static const Color _c2 = Color.fromARGB(172, 95, 2, 38);

  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();
  bool _down = false;

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        if (widget.enabled) {
          HapticFeedback.lightImpact();
          widget.onPressed();
        }
      },
      child: AnimatedScale(
        scale: _down ? .98 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedBuilder(
          animation: _loop,
          builder: (context, _) {
            final angle = _loop.value * 2 * math.pi;
            final pulse = (math.sin(angle) + 1) / 2;
            final ringAlpha = 0.55 + 0.45 * pulse;

            // 🔹 Blur reduzido (antes 18–36, agora 10–18)
            final shadow = [
              BoxShadow(
                color: _c1.withOpacity(.18 + .12 * pulse),
                blurRadius: 10 + 8 * pulse,
                spreadRadius: 0.8 + 1.2 * pulse,
              ),
            ];

            return Container(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius + 2),
                gradient: SweepGradient(
                  colors: [
                    _c1.withOpacity(ringAlpha),
                    _c2.withOpacity(ringAlpha),
                    _c1.withOpacity(ringAlpha),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                  transform: GradientRotation(angle),
                ),
                boxShadow: shadow,
              ),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: _c1,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.5,
        child: IgnorePointer(ignoring: !widget.enabled, child: button),
      ),
    );
  }
}

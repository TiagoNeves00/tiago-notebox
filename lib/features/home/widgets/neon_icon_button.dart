import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Botão de ícone com brilho neon animado, com blur reduzido.
class NeonIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? glow;
  final double size;

  const NeonIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.glow,
    this.size = 18,
  });

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton>
    with TickerProviderStateMixin {
  bool down = false;

  static const Color _c1 = Color(0xFFEA00FF);
  static const Color _c2 = Color.fromARGB(172, 95, 2, 38);

  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = widget.glow ?? _c1;
    final iconColor =
        Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;

    final button = AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final angle = _loop.value * 2 * math.pi;
        final pulse = (math.sin(angle) + 1) / 2;
        final ringAlpha = 0.55 + 0.45 * pulse;

        // 🔹 Blur reduzido (antes 14–24, agora 7–12)
        final shadow = [
          BoxShadow(
            color: glow.withOpacity(.25 + .15 * pulse),
            blurRadius: 4 + 4 * pulse,
            spreadRadius: 0.8 + 0.8 * pulse,
          ),
        ];

        final pad = (widget.size * 0.25).clamp(6.0, 12.0);

        return Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
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
            padding: EdgeInsets.all(pad),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _c1,
            ),
            child: Icon(widget.icon, color: iconColor, size: widget.size),
          ),
        );
      },
    );

    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTapDown: (_) => setState(() => down = true),
        onTapCancel: () => setState(() => down = false),
        onTapUp: (_) {
          setState(() => down = false);
          HapticFeedback.selectionClick();
          widget.onPressed();
        },
        child: AnimatedScale(
          scale: down ? .92 : 1,
          duration: const Duration(milliseconds: 90),
          child: button,
        ),
      ),
    );
  }
}

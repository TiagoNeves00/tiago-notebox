import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NeonIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color glow; // cor do brilho

  const NeonIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.glow = const Color(0xFFEA00FF),
  });

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final core = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.glow.withOpacity(.35),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(widget.icon, color: Colors.white),
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
          child: core,
        ),
      ),
    );
  }
}

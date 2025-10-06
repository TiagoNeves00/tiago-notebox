import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Botão de ícone com brilho neon no novo tema.
/// Agora com parâmetro [size] para controlar o tamanho do ícone.
class NeonIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  /// Cor do brilho. Se null, usa `Theme.of(context).colorScheme.secondary`.
  final Color? glow;

  /// Tamanho do ícone (default 30).
  final double size;

  const NeonIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.glow,
    this.size = 30, // ↑ aumentado
  });

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final themeNeon = Theme.of(context).colorScheme.secondary;
    final glow = widget.glow ?? themeNeon;
    final iconColor =
        Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;

    final shadowA = BoxShadow(color: glow.withOpacity(.35), blurRadius: 6);
    final shadowB = BoxShadow(color: glow.withOpacity(.18), blurRadius: 3);

    // padding proporcional ao tamanho do ícone para o glow respirar
    final pad = (widget.size * 0.25).clamp(6.0, 12.0);

    final core = Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [shadowA, shadowB],
      ),
      child: Icon(widget.icon, color: iconColor, size: widget.size),
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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notebox/theme/app_theme.dart'; // NeonCtx / NeonColors

class FlowNeonDivider extends StatefulWidget {
  const FlowNeonDivider({super.key, this.color});
  /// Se null, usa context.neon.pink
  final Color? color;

  @override
  State<FlowNeonDivider> createState() => _FlowNeonDividerState();
}

class _FlowNeonDividerState extends State<FlowNeonDivider>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pink = widget.color ?? context.neon.pink;

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        // Partições do percurso total (somam ~1.0)
        const leftSpan = 0.44; // linha esquerda
        const dotSpan = 0.12;  // cruzar a bolinha
        const rightSpan = 0.44; // linha direita

        final p = _c.value; // 0..1

        // Progresso local por segmento
        double? uLeft, uDot, uRight;
        if (p < leftSpan) {
          uLeft = (p / leftSpan);
        } else if (p < leftSpan + dotSpan) {
          uDot = (p - leftSpan) / dotSpan;
        } else {
          uRight = (p - leftSpan - dotSpan) / rightSpan;
        }

        // Linha com highlight na posição u [0..1]
        Widget line(double? u) {
          final pos = (u ?? 0.0).clamp(0.0, 1.0);
          const w = 0.10; // largura da janela
          final a = (pos - w).clamp(0.0, 1.0);
          final b = pos;
          final c = (pos + w).clamp(0.0, 1.0);

          return Container(
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(color: pink.withOpacity(.35), blurRadius: 3),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  pink.withOpacity(.18),
                  pink.withOpacity(u == null ? .25 : .85),
                  pink.withOpacity(.18),
                ],
                stops: [a, b, c],
              ),
            ),
          );
        }

        // Bolinha com anel em rotação quando em uDot
        Widget dot() {
          final angle = (uDot ?? 0.0) * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              // halo
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: pink.withOpacity(.45), blurRadius: 12),
                    BoxShadow(color: pink.withOpacity(.25), blurRadius: 6),
                  ],
                ),
              ),
              // anel
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      pink.withOpacity(.15),
                      pink.withOpacity(uDot == null ? .55 : .95),
                      pink.withOpacity(.15),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    transform: GradientRotation(angle),
                  ),
                ),
              ),
              // miolo
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: pink, shape: BoxShape.circle),
              ),
            ],
          );
        }

        return SizedBox(
          height: 18,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: line(uLeft)),
              const SizedBox(width: 15),
              dot(),
              const SizedBox(width: 15),
              Expanded(child: line(uRight)),
            ],
          ),
        );
      },
    );
  }
}

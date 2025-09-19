import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernFab extends StatefulWidget {
  final VoidCallback onCreate;
  const ModernFab({super.key, required this.onCreate});

  @override
  State<ModernFab> createState() => _S();
}

class _S extends State<ModernFab> with SingleTickerProviderStateMixin {
  late final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: down ? .94 : 1,
      duration: const Duration(milliseconds: 110),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => down = true);
          c.forward(from: 0);
        },
        onTapCancel: () => setState(() => down = false),
        onTapUp: (_) {
          setState(() => down = false);
          HapticFeedback.lightImpact();
          widget.onCreate();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFEA00FF), Color(0xFFEA00FF)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                ),
              ),
            ),
            AnimatedRotation(
              turns: down ? .125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.add_rounded, color: cs.onPrimary, size: 48),
            ),
            FadeTransition(
              opacity: CurvedAnimation(parent: c, curve: Curves.easeOut),
              child: const DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: SizedBox(width: 1, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/router/transitions.dart
import 'dart:ui';
import 'package:flutter/cupertino.dart';

typedef TB = Widget Function(BuildContext, Animation<double>, Animation<double>, Widget);

class Transitions {
  static TB fadeThrough = (_, a, __, c) => FadeTransition(opacity: a, child: c);

  static TB sharedAxisX = (_, a, __, c) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved),
      child: FadeTransition(opacity: curved, child: c),
    );
  };

  static TB sharedAxisY = (_, a, __, c) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
      child: FadeTransition(opacity: curved, child: c),
    );
  };

  static TB sharedAxisZ = (_, a, __, c) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: .98, end: 1).animate(curved),
        child: c,
      ),
    );
  };

  static TB blurFade = (_, a, __, c) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (_, __) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: (1 - curved.value) * 10, sigmaY: (1 - curved.value) * 10),
          child: c,
        ),
      ),
    );
  };

  static TB cupertino = (_, a, sa, c) => CupertinoPageTransition(
        primaryRouteAnimation: a,
        secondaryRouteAnimation: sa,
        linearTransition: true,
        child: c,
      );
}

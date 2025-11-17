import 'package:flutter/material.dart';

typedef TB = Widget Function(
  BuildContext,
  Animation<double>,
  Animation<double>,
  Widget,
);

class Transitions {
  static TB fadeOnly = (_, animation, __, child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
      child: child,
    );
  };
}

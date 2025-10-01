import 'package:flutter/material.dart';

@immutable
class NeonColors extends ThemeExtension<NeonColors> {
  final Color bg, surface, onSurface, outline, pink, cyan, warn;
  const NeonColors({
    required this.bg, required this.surface, required this.onSurface,
    required this.outline, required this.pink, required this.cyan, required this.warn,
  });
  @override
  NeonColors copyWith({
    Color? bg,
    Color? surface,
    Color? onSurface,
    Color? outline,
    Color? pink,
    Color? cyan,
    Color? warn,
  }) {
    return NeonColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      outline: outline ?? this.outline,
      pink: pink ?? this.pink,
      cyan: cyan ?? this.cyan,
      warn: warn ?? this.warn,
    );
  }

  @override
  NeonColors lerp(covariant NeonColors? o, double t) {
    if (o == null) return this;
    return NeonColors(
      bg: Color.lerp(bg, o.bg, t)!,
      surface: Color.lerp(surface, o.surface, t)!,
      onSurface: Color.lerp(onSurface, o.onSurface, t)!,
      outline: Color.lerp(outline, o.outline, t)!,
      pink: Color.lerp(pink, o.pink, t)!,
      cyan: Color.lerp(cyan, o.cyan, t)!,
      warn: Color.lerp(warn, o.warn, t)!,
    );
  }
}

extension NeonCtx on BuildContext {
  NeonColors get neon => Theme.of(this).extension<NeonColors>()!;
}

ThemeData neonDarkTheme() {
  const bg = Color(0xFF0A0F1A);     // azul-noite
  const surface = Color(0xFF101827); // cartões/inputs
  const onSurface = Color(0xFFE4EEFF);
  const outline = Color(0xFF283445); // cinza-azulado
  const pink = Color(0xFFEA00FF);    // magenta neon
  const cyan = Color(0xFF00F5FF);    // ciano neon
  const warn = Color(0xFFFFB03A);    // lanternas/realce

  final cs = const ColorScheme.dark(
    surface: surface, onSurface: onSurface, primary: pink, secondary: cyan,
    outlineVariant: outline, background: bg,
  );

  return ThemeData(
    useMaterial3: true, colorScheme: cs, scaffoldBackgroundColor: bg,
    textTheme: Typography.whiteMountainView.apply(
      bodyColor: onSurface.withOpacity(.92), displayColor: onSurface),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent),
    iconTheme: const IconThemeData(color: onSurface),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: outline)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: outline)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: pink, width: 1.2)),
    ),
    extensions: const [
      NeonColors(bg: bg, surface: surface, onSurface: onSurface,
        outline: outline, pink: pink, cyan: cyan, warn: warn),
    ],
  );
}

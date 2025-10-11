import 'package:flutter/material.dart';

class BgTextPalette {
  final Color title;
  final Color body;
  final Color hint;
  final Color divider;
  const BgTextPalette({
    required this.title,
    required this.body,
    required this.hint,
    required this.divider,
  });

  factory BgTextPalette.lightOnDark() => const BgTextPalette(
        title: Colors.white,
        body: Color(0xFFEFEFF1),
        hint: Color(0x99FFFFFF),
        divider: Color(0x33FFFFFF),
      );

  factory BgTextPalette.darkOnLight() => const BgTextPalette(
        title: Color(0xFF0B1220),
        body: Color(0xFF141B2A),
        hint: Color(0x66141B2A),
        divider: Color(0x22141B2A),
      );
}

/// Formatos aceites para sólidos:
///  - solid:#RRGGBB  |  solid:#AARRGGBB
///  - solid:white | solid:black
/// Retorna null se não for sólido **ou** se for inválido (sem lançar exceções).
Color? parseSolid(String? key) {
  if (key == null || !key.startsWith('solid:')) return null;

  final v = key.substring('solid:'.length).trim();
  if (v.isEmpty) return null;

  switch (v.toLowerCase()) {
    case 'white':
      return Colors.white;
    case 'black':
      return Colors.black;
  }

  if (v.startsWith('#')) {
    final hex = v.substring(1);
    try {
      final normalized = hex.length == 6 ? 'FF$hex' : hex; // garante alpha
      return Color(int.parse(normalized, radix: 16));
    } catch (_) {
      return null;
    }
  }
  return null;
}

BgTextPalette paletteFor(String? bgKey, Brightness system) {
  final solid = parseSolid(bgKey);
  if (solid != null) {
    final lum = solid.computeLuminance();
    return lum > 0.5 ? BgTextPalette.darkOnLight() : BgTextPalette.lightOnDark();
  }
  return system == Brightness.light
      ? BgTextPalette.darkOnLight()
      : BgTextPalette.lightOnDark();
}

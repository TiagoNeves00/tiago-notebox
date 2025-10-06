import 'package:flutter/material.dart';

class BgPalette {
  final Color title;
  final Color body;
  final Color hint;
  final Color divider;
  const BgPalette(this.title, this.body, this.hint, this.divider);
}

/// Parser de cor sólida: "solid:<hexIntSem0x>"
Color? parseSolid(String? key) {
  if (key == null) return null;
  if (!key.startsWith('solid:')) return null;
  final hex = key.split(':').last;
  // aceita "ff00ff" ou "ff00ffaa" etc; se faltar alpha, assume 0xFF
  final val = int.parse(hex, radix: 16);
  // se veio sem alpha (<= 0xFFFFFF), força 0xFF000000 |
  final withAlpha = (val <= 0xFFFFFF) ? (0xFF000000 | val) : val;
  return Color(withAlpha);
}

/// Paleta para imagem conhecida OU cor sólida.
/// Para sólidos: ajusta contraste com base na luminância.
BgPalette paletteFor(String? bgKey, Brightness brightness) {
  // Sólidos
  final solid = parseSolid(bgKey);
  if (solid != null) {
    final lum = solid.computeLuminance(); // 0..1
    final on = lum > 0.5 ? const Color(0xFF111111) : Colors.white;
    final hint = on.withOpacity(0.70);
    final div = on.withOpacity(0.22);
    return BgPalette(on, on.withOpacity(.92), hint, div);
  }

  // IMAGENS → usa presets simples por chave (mantém os existentes se já tinhas).
  // Defaults por brilho do tema como fallback.
  if (bgKey?.contains('dark') == true || brightness == Brightness.dark) {
    return const BgPalette(Colors.white, Color(0xFFECECEC), Colors.white70, Colors.white24);
  } else {
    return const BgPalette(Color(0xFF111111), Color(0xFF1E1E1E), Color(0x99000000), Color(0x33000000));
  }
}

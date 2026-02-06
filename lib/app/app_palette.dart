// lib/theme/app_palette.dart
import 'package:flutter/material.dart';

/// Fonte única de verdade para:
/// - cores de fundo das notas (sólidas)
/// - cores de pastas
/// - imagens de fundo das notas (assets)
///
/// Convenção:
/// - bgKey para cor sólida = "solid:#RRGGBB"
/// - bgKey para imagem = "assets/....webp"
class AppPalette {
  AppPalette._();

  // -----------------------------
  // NOTE BACKGROUNDS (SOLID)
  // -----------------------------
  static const List<Color> noteBgSolids = [
    Color(0xFF08131D), // base dark (teu fallback)
    Color(0xFF0E1720),
    Color(0xFF101B2A),
    Color(0xFF141A1F),
    Color(0xFF1A1F2A),

    Color(0xFFF7F4EE), // paper-ish
    Color(0xFFFFFFFF), // white
    Color(0xFFEAF2FF), // baby blue
    Color(0xFFFFF2E6), // warm
    Color(0xFFEFFAF2), // mint

    Color(0xFF1B0B2E), // deep purple
    Color(0xFF2A0E3E),
    Color(0xFF0B1B2E), // deep blue
  ];

  // -----------------------------
  // FOLDER COLORS
  // -----------------------------
  static const List<Color> folderColors = [
    Color(0xFFEA00FF), // neon pink (marca)
    Color(0xFF00E5FF), // neon cyan
    Color(0xFF7C4DFF), // purple
    Color(0xFF00C853), // green
    Color(0xFFFFD600), // yellow
    Color(0xFFFF6D00), // orange
    Color(0xFFFF1744), // red
    Color(0xFF90A4AE), // neutral
    Color(0xFF3D5AFE), // blue
    Color(0xFF1DE9B6), // mint
  ];

  // -----------------------------
  // NOTE BACKGROUNDS (IMAGES)
  // -----------------------------
  static const List<String> noteBgImages = [
    'assets/note_bg/old_paper_bg.webp',
    'assets/note_bg/purple_flower_bg.webp',
    'assets/note_bg/blue_ocean_sky_bg.webp',
    'assets/note_bg/orange_water_sky_bg.webp',
    'assets/note_bg/baby_blue_bg.webp',
    'assets/note_bg/dark_night_bg.webp',
    'assets/note_bg/white_bg.webp',
    'assets/note_bg/bridge_low_sun_bg.webp',
    'assets/note_bg/night_city_1_bg.webp',
  ];

  // -----------------------------
  // HELPERS (bgKey encoding)
  // -----------------------------
  static String solidToBgKey(Color c) => 'solid:${_toHexRgb(c)}';

  static Color? bgKeyToSolid(String? key) {
    if (key == null) return null;
    if (!key.startsWith('solid:')) return null;

    final hex = key.substring('solid:'.length).trim();
    return _fromHexRgb(hex);
    }

  static bool isSolidBgKey(String? key) => bgKeyToSolid(key) != null;

  static bool isImageBgKey(String? key) =>
      key != null && key.startsWith('assets/');

  static String _toHexRgb(Color c) {
    // #RRGGBB (ignorando alpha)
    final v = c.value & 0x00FFFFFF;
    return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static Color? _fromHexRgb(String hex) {
    // aceita "#RRGGBB" ou "RRGGBB"
    final h = hex.startsWith('#') ? hex.substring(1) : hex;
    if (h.length != 6) return null;

    final parsed = int.tryParse(h, radix: 16);
    if (parsed == null) return null;

    return Color(0xFF000000 | parsed);
  }
}

// lib/theme/bg_text_palettes.dart
import 'package:flutter/material.dart';

class BgTextPalette {
  final Color title, body, hint, divider, icons;
  const BgTextPalette({
    required this.title, required this.body, required this.hint,
    required this.divider, required this.icons,
  });
}

const _w = Colors.white, _w70 = Colors.white70, _w24 = Color(0x3DFFFFFF);
const _b = Colors.black, _b70 = Colors.black87, _b24 = Color(0x24000000);

// PREENCHER com as tuas cores estudadas:
const Map<String, BgTextPalette> kBgTextPalettes = {
  // :D
  'assets/note_bg/old_paper_bg.webp': BgTextPalette(
    title: _b, body: _b70, hint: _b70, divider: _b24, icons: _b),
  // :D
  'assets/note_bg/purple_flower_bg.webp': BgTextPalette(
    title: _b, body: _b70, hint: _b70, divider: _b24, icons: _b),
  // :D 
  'assets/note_bg/blue_ocean_sky_bg.webp': BgTextPalette(
    title: _b, body: _b70, hint: _b70, divider: _b24, icons: _b),
  // :D
  'assets/note_bg/orange_water_sky_bg.webp': BgTextPalette(
    title: _w, body: _w70, hint: _w70, divider: _w24, icons: _w),
  // :D
  'assets/note_bg/baby_blue_bg.webp': BgTextPalette(
    title: _b, body: _b70, hint: _b70, divider: _b24, icons: _b),
  // :D
  'assets/note_bg/dark_night_bg.webp': BgTextPalette(
    title: _w, body: _w70, hint: _w70, divider: _w24, icons: _w),
  // :D
  'assets/note_bg/white_bg.webp': BgTextPalette(
    title: _b, body: _b70, hint: _b70, divider: _b24, icons: _b),
  // :D
  'assets/note_bg/bridge_low_sun_bg.webp': BgTextPalette(
    title: _w, body: _w70, hint: _w70, divider: _w24, icons: _w),
  // :D
  'assets/note_bg/night_city_1_bg.webp': BgTextPalette(
    title: _w, body: _w70, hint: _w70, divider: _w24, icons: _w),
};

// fallback rápido caso não exista chave:
BgTextPalette paletteFor(String? bgKey, Brightness themeBrightness) {
  if (bgKey != null && kBgTextPalettes.containsKey(bgKey)) {
    return kBgTextPalettes[bgKey]!;
  }
  final isDark = themeBrightness == Brightness.dark;
  return isDark
      ? const BgTextPalette(title: _w, body: _w, hint: _w70, divider: _w24, icons: _w)
      : const BgTextPalette(title: _b, body: _b70, hint: _b70, divider: _b24, icons: _b);
}

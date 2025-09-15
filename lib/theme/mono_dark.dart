import 'package:flutter/material.dart';


const _bg = Color(0xFF121212);
const _txt = Color(0xFFE0E0E0);
const _txt2 = Color(0xFFB0B0B0);
const _line = Color(0xFF444444);
const _accent = Color(0xFF888888);

final monoDarkScheme = const ColorScheme.dark().copyWith(
  surface: _bg,
  background: _bg,
  primary: _accent,
  onPrimary: _txt,
  secondary: _txt2,
  onSecondary: _txt,
  surfaceTint: Colors.transparent,
  onSurface: _txt,
  onSurfaceVariant: _txt2,
  outline: _line,
  outlineVariant: _line,
);
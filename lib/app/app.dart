import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/app/router/router.dart';
import 'package:notebox/theme/app_theme.dart';
import 'package:notebox/theme/theme_mode.dart';

class NoteBoxApp extends ConsumerWidget {
  const NoteBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    return DynamicColorBuilder(
      builder: (lightDyn, darkDyn) {
        return MaterialApp.router(
          title: 'NoteBox',
          theme: neonDarkTheme(),
          darkTheme: neonDarkTheme(),
          themeMode: ThemeMode.dark,
          routerConfig: appRouter,
        );
      },
    );
  }
}

// --- Cores base da palete ---
const _bg = Color(0xFF121212);   // fundo
const _txt = Color(0xFFE0E0E0);  // texto principal
const _txt2 = Color(0xFFB0B0B0); // texto secundário
const _line = Color(0xFF444444); // divisores
const _accent = Color(0xFF888888); // acento

const _bgLight = Color(0xFFFAFAFA);
const _txtDark = Color(0xFF212121);
const _txtSec = Color(0xFF616161);
const _line_light = Color(0xFFBDBDBD);
const _accent_light = Color(0xFF757575);

final monoDarkScheme = const ColorScheme.dark().copyWith(
  surface: _bg,
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

final monoLightScheme = const ColorScheme.light().copyWith(
  surface: _bgLight,
  primary: _accent_light,
  onPrimary: _txtDark,
  secondary: _txtSec,
  onSecondary: _txtDark,
  surfaceTint: Colors.transparent,
  onSurface: _txtDark,
  onSurfaceVariant: _txtSec,
  outline: _line_light,
  outlineVariant: _line_light,
);



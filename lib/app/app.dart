import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/app/router.dart';
import 'package:notebox/theme/theme_mode.dart';

class NoteBoxApp extends ConsumerWidget {
  const NoteBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return DynamicColorBuilder(
      builder: (lightDyn, darkDyn) {
        return MaterialApp.router(
          title: 'NoteBox',
          theme: _lightMono(),
          darkTheme: _darkMono(),
          themeMode: mode,
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

final monoLightScheme = const ColorScheme.light().copyWith(
  surface: _bgLight,
  background: _bgLight,
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

ThemeData _darkMono() => ThemeData(
  useMaterial3: true,
  colorScheme: monoDarkScheme,
  scaffoldBackgroundColor: monoDarkScheme.surface,
  dividerTheme: DividerThemeData(color: monoDarkScheme.outline, thickness: 1),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    foregroundColor: monoDarkScheme.onSurface,
  ),
  iconTheme: IconThemeData(color: monoDarkScheme.onSurface),
  chipTheme: ChipThemeData(
    side: BorderSide(color: monoDarkScheme.outline),
    backgroundColor: monoDarkScheme.surface,
    selectedColor: _accent.withOpacity(.18),
    labelStyle: TextStyle(color: monoDarkScheme.onSurface),
  ),
);

ThemeData _lightMono() => ThemeData(
  useMaterial3: true,
  colorScheme: monoLightScheme,
  scaffoldBackgroundColor: monoLightScheme.surface,
  dividerTheme: DividerThemeData(color: monoLightScheme.outline, thickness: 1),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    foregroundColor: monoLightScheme.onSurface,
  ),
  iconTheme: IconThemeData(color: monoLightScheme.onSurface),
  chipTheme: ChipThemeData(
    side: BorderSide(color: monoLightScheme.outline),
    backgroundColor: monoLightScheme.surface,
    selectedColor: _accent.withOpacity(.15),
    labelStyle: TextStyle(color: monoLightScheme.onSurface),
  ),
);

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/features/home_page.dart';
import 'package:notebox/theme/app_colors.dart';
import 'package:notebox/theme/theme_mode.dart';



class NoteBoxApp extends ConsumerWidget {
  const NoteBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return DynamicColorBuilder(builder: (lightDyn, darkDyn) {
      final light = ThemeData(
        useMaterial3: true,
        colorScheme: lightDyn ??
            ColorScheme.fromSeed(seedColor: AppColors.light.brand),
        extensions: const [AppColors.light],
      );
      final dark = ThemeData(
        useMaterial3: true,
        colorScheme: darkDyn ??
            ColorScheme.fromSeed(
              seedColor: AppColors.dark.brand,
              brightness: Brightness.dark,
            ),
        extensions: const [AppColors.dark],
      );
      return MaterialApp(
        title: 'NoteBox',
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        home: const HomePage(),
      );
    });
  }
}

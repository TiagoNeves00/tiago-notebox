// app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/app/notes_tasks_tabs.dart';
import 'package:notebox/features/editor/bg_picker_sheet.dart';
import 'package:notebox/features/editor/editor_baseline.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/editor/editor_save_handler.dart';
import 'package:notebox/features/home/widgets/folder_pill.dart';
import 'package:notebox/features/home/widgets/neon_icon_button.dart';
import 'package:notebox/theme/theme_mode.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  bool _isHome(String loc) =>
      loc.startsWith('/notes') || loc.startsWith('/tasks');

  String _titleFor(String loc) {
    if (loc.startsWith('/folders')) return 'Pastas';
    if (loc.startsWith('/settings')) return 'Settings';
    if (loc.startsWith('/edit')) return 'Nota';
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.toString();
    final isHome = _isHome(loc);
    final isNotes = loc.startsWith('/notes');
    final isEdit = loc.startsWith('/edit');

    final draft = ref.watch(editorProvider);
    final base = ref.watch(editorBaselineProvider);
    final dirty = isDirty(draft, base);

    final hasBg = isEdit && ref.watch(editorProvider).bgKey != null;

    // handler registado pelo NoteEditorPage
    final saveHandler = ref.watch(editorSaveHandlerProvider);

    if (!isEdit && saveHandler != null) {
      Future.microtask(() {
        ref.read(editorSaveHandlerProvider.notifier).state = null;
      });
    }

    const glowPink = Color(0xFFEA00FF);

    Widget neonIcon({
      required IconData icon,
      required VoidCallback? onPressed,
      String? tooltip,
      Color glow = glowPink,
      bool enabled = true,
    }) {
      final btn = NeonIconButton(
        icon: icon,
        tooltip: tooltip,
        glow: glow,
        onPressed: onPressed ?? () {},
      );
      return Opacity(
        opacity: enabled ? 1 : 0.45,
        child: IgnorePointer(ignoring: !enabled, child: btn),
      );
    }

    Future<void> _saveAndMaybePop({required bool popAfter}) async {
      final fn = saveHandler;
      if (fn != null) {
        await fn();
        if (!context.mounted) return;
      }

      if (popAfter) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/notes');
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: !isEdit,
      extendBodyBehindAppBar: isEdit,
      appBar: AppBar(
        backgroundColor: isEdit ? Colors.transparent : null,
        surfaceTintColor: isEdit ? Colors.transparent : null,
        elevation: isEdit ? 0 : null,
        scrolledUnderElevation: 0,
        systemOverlayStyle: hasBg ? SystemUiOverlayStyle.light : null,
        foregroundColor: hasBg ? Colors.white : null,
        iconTheme: hasBg ? const IconThemeData(color: Colors.white) : null,
        actionsIconTheme: hasBg
            ? const IconThemeData(color: Colors.white)
            : null,
        leading: isHome
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Voltar',
                onPressed: () async {
                  if (isEdit && dirty) {
                    await _saveAndMaybePop(popAfter: true);
                  } else {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/notes');
                    }
                  }
                },
              ),
        titleSpacing: 0,
        title: isHome
            ? NotesTasksTabs(isNotes: isNotes)
            : Text(
                _titleFor(loc),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
        actions: isHome
            ? [
                IconTheme(
                  data: const IconThemeData(size: 32),
                  child: neonIcon(
                    icon: Icons.brightness_6,
                    tooltip: 'Tema',
                    glow: glowPink,
                    onPressed: () =>
                        ref.read(themeModeProvider.notifier).toggle(),
                  ),
                ),
                const SizedBox(width: 8),
                IconTheme(
                  data: const IconThemeData(size: 32),
                  child: neonIcon(
                    icon: Icons.folder_open,
                    tooltip: 'Pastas',
                    glow: glowPink,
                    onPressed: () => context.push('/folders'),
                  ),
                ),
                const SizedBox(width: 8),
                IconTheme(
                  data: const IconThemeData(size: 32),
                  child: neonIcon(
                    icon: Icons.settings,
                    tooltip: 'Settings',
                    glow: glowPink,
                    onPressed: () => context.push('/settings'),
                  ),
                ),
                const SizedBox(width: 12),
              ]
            : (isEdit
                  ? [
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: FolderPill(),
                      ),
                      const SizedBox(width: 24),
                      IconTheme(
                        data: const IconThemeData(size: 32),
                        child: neonIcon(
                          icon: Icons.wallpaper_rounded,
                          tooltip: 'Fundo',
                          glow: glowPink,
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const BgPickerSheet(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      IconTheme(
                        data: const IconThemeData(size: 32),
                        child: neonIcon(
                          icon: Icons.check_circle_outline_rounded,
                          tooltip: 'Guardar',
                          glow: glowPink,
                          enabled: dirty && saveHandler != null,
                          onPressed: (dirty && saveHandler != null)
                              ? () async => _saveAndMaybePop(popAfter: true)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ]
                  : null),
      ),
      body: child,
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <- novo
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/app/notes_tasks_tabs.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/data/repos/revisions_repo.dart';
import 'package:notebox/features/editor/editor_baseline.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/editor/note_bg_picker.dart';
import 'package:notebox/features/home/widgets/folder_pill.dart';
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

  int? _editingIdFrom(String loc) {
    final m = RegExp(r'^/edit/(\d+)').firstMatch(loc);
    return m != null ? int.tryParse(m.group(1)!) : null;
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

    final inactiveColor = Color.fromARGB(82, 255, 255, 255);
    const white = Color.fromARGB(255, 255, 255, 255); // branco (Material A700)

    Future<void> saveEditorIfDirty() async {
      if (!dirty) return;
      final id = _editingIdFrom(loc);
      final savedId = await ref
          .read(notesRepoProvider)
          .upsert(
            id: id,
            title: draft.title,
            body: draft.body,
            color: draft.color,
            folderId: draft.folderId,
            bgKey: draft.bgKey, // <- inclui fundo
          );
      await ref
          .read(revisionsRepoProvider)
          .add(
            savedId,
            jsonEncode({
              'title': draft.title,
              'body': draft.body,
              'color': draft.color,
              'folderId': draft.folderId,
              'bgKey': draft.bgKey,
            }),
          );
      ref.read(editorBaselineProvider.notifier).state = draft;
    }

    return Scaffold(
      resizeToAvoidBottomInset: !isEdit,
      extendBodyBehindAppBar: isEdit, // <- cobre status bar
      appBar: AppBar(
        backgroundColor: isEdit ? Colors.transparent : null,
        surfaceTintColor: isEdit ? Colors.transparent : null,
        elevation: isEdit ? 0 : null,
        scrolledUnderElevation: 0,
        systemOverlayStyle: hasBg ? SystemUiOverlayStyle.light : null,
        foregroundColor: hasBg ? Colors.white : null, // <- texto "Nota"
        iconTheme: hasBg ? const IconThemeData(color: Colors.white) : null,
        actionsIconTheme: hasBg
            ? const IconThemeData(color: Colors.white)
            : null,
        leading: isHome
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  if (isEdit) await saveEditorIfDirty();
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/notes');
                  }
                },
              ),
        titleSpacing: 0,
        title: isHome ? NotesTasksTabs(isNotes: isNotes) : Text(_titleFor(loc)),
        actions: isHome
            ? [
                IconButton(
                  tooltip: 'Tema',
                  icon: const Icon(Icons.brightness_6),
                  onPressed: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
                IconButton(
                  tooltip: 'Pastas',
                  icon: const Icon(Icons.folder_open),
                  onPressed: () => context.push('/folders'),
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.push('/settings'),
                ),
              ]
            : (isEdit
                  ? [
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: FolderPill(),
                      ),
                      IconButton(
                        tooltip: 'Customize',
                        icon: const Icon(Icons.image_outlined, size: 30),
                        onPressed: () => showNoteBgPicker(context, ref),
                      ),

                      IconButton(
                        tooltip: 'Guardar',
                        onPressed: dirty
                            ? () async {
                                await saveEditorIfDirty();
                                context.pop();
                              }
                            : null,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 32,
                            key: ValueKey(dirty),
                            color: dirty ? white : inactiveColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ]
                  : null),
      ),
      body: child,
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/app/notes_tasks_tabs.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/data/repos/revisions_repo.dart';
import 'package:notebox/features/editor/editor_baseline.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/home/providers/folder_colors.dart';
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

    Future<void> saveEditorIfDirty() async {
      final st = ref.read(editorProvider);
      final base = ref.read(editorBaselineProvider);
      final dirty = isDirty(st, base);
      if (!dirty) return;

      // extrai id se existir em /edit/:id
      int? id;
      final segs = loc.split('/');
      if (segs.length >= 3) {
        final maybe = int.tryParse(segs.last);
        if (maybe != null) id = maybe;
      }

      final savedId = await ref
          .read(notesRepoProvider)
          .upsert(
            id: id,
            title: st.title,
            body: st.body,
            color: st.color,
            folderId: st.folderId,
          );
      await ref
          .read(revisionsRepoProvider)
          .add(
            savedId,
            jsonEncode({
              'title': st.title,
              'body': st.body,
              'color': st.color,
              'folderId': st.folderId,
            }),
          );
      ref.read(editorBaselineProvider.notifier).state = st;
    }

    return Scaffold(
      appBar: AppBar(
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
                      const Padding(padding: EdgeInsets.only(right: 6)),
                      const _FolderButtonSmall(),
                      IconButton(
                        tooltip: 'Guardar',
                        icon: const Icon(Icons.check_circle_rounded),
                        onPressed: () async {
                          await saveEditorIfDirty();
                          if (context.mounted) context.pop();
                        },
                      ),
                      const SizedBox(width: 4),
                    ]
                  : null),
      ),
      body: child,
    );
  }
}

/// Seletor compacto para o AppBar do editor
class _FolderButtonSmall extends ConsumerWidget {
  const _FolderButtonSmall();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentId = ref.watch(editorProvider).folderId;
    final folders$ = ref.watch(foldersRepoProvider).watchAll();
    final colorsMap = ref
        .watch(folderColorsProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int, int?>{});

    return StreamBuilder<List<Folder>>(
      stream: folders$,
      builder: (_, snap) {
        final folders = snap.data ?? const <Folder>[];
        final name = currentId == null
            ? 'Sem pasta'
            : folders
                  .firstWhere(
                    (f) => f.id == currentId,
                    orElse: () => Folder(id: -1, name: 'Pasta', order: 0),
                  )
                  .name;
        final cInt = currentId != null ? colorsMap[currentId] : null;
        final color = cInt != null
            ? Color(cInt)
            : Theme.of(context).colorScheme.outlineVariant;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilledButton.tonal(
            onPressed: () => _pickFolder(context, ref, currentId),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.folder_open_rounded,
                  size: 22,
                ), // Added icon here
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 8,
                  backgroundColor: color,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(name, overflow: TextOverflow.ellipsis),
                const Icon(Icons.expand_more, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFolder(
    BuildContext ctx,
    WidgetRef ref,
    int? currentId,
  ) async {
    final repo = ref.read(foldersRepoProvider);
    final folders = await repo.watchAll().first;
    final colorsMap = ref
        .read(folderColorsProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int, int?>{});
    Color dot(int? id) {
      final theme = Theme.of(ctx).colorScheme.outlineVariant;
      if (id == null) return theme;
      final v = colorsMap[id];
      return v != null ? Color(v) : theme;
    }

    final chosen = await showModalBottomSheet<int?>(
      context: ctx,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Escolhe a pasta')),
            RadioListTile<int?>(
              value: null,
              groupValue: currentId,
              title: const Text('Sem pasta'),
              secondary: CircleAvatar(
                backgroundColor: dot(null),
                radius: 12,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                ),
              ),
              onChanged: (v) => Navigator.pop(sheetCtx, v),
            ),
            ...folders.map(
              (f) => RadioListTile<int?>(
                value: f.id,
                groupValue: currentId,
                title: Text(f.name),
                secondary: CircleAvatar(
                  backgroundColor: dot(f.id),
                  radius: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                  ),
                ),
                onChanged: (v) => Navigator.pop(sheetCtx, v),
              ),
            ),
          ],
        ),
      ),
    );

    ref.read(editorProvider.notifier).set(folderId: chosen);
  }
}

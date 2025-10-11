import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/home/providers/folder_colors.dart';

class FolderPill extends ConsumerStatefulWidget {
  const FolderPill({super.key});

  @override
  ConsumerState<FolderPill> createState() => _FolderPillState();
}

class _FolderPillState extends ConsumerState<FolderPill> {
  bool _down = false;

  static const glowPink = Color(0xFFEA00FF);
  static const glowCyan = Color(0xFF00F5FF);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;
    final currentId = ref.watch(editorProvider).folderId;
    final colors = ref.watch(folderColorsProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int,int?>{});
    final folders$ = ref.watch(foldersRepoProvider).watchAll();

    return StreamBuilder<List<Folder>>(
      stream: folders$,
      builder: (_, snap) {
        final folders = snap.data ?? const <Folder>[];
        final name = currentId == null
            ? 'Sem pasta'
            : folders.firstWhere(
                (f) => f.id == currentId,
                orElse: () => const Folder(id: -1, name: 'Pasta', order: 0),
              ).name;

        final cInt = currentId != null ? colors[currentId] : null;
        final dot = cInt != null ? Color(cInt) : cs.outlineVariant;

        return Semantics(
          button: true,
          label: 'Selecionar pasta',
          child: GestureDetector(
            onTapDown: (_) => setState(() => _down = true),
            onTapCancel: () => setState(() => _down = false),
            onTapUp: (_) {
              setState(() => _down = false);
              _openPicker(context, ref, currentId);
            },
            child: AnimatedScale(
              scale: _down ? .96 : 1,
              duration: const Duration(milliseconds: 90),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: glowPink.withOpacity(.35),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E1720).withOpacity(.55),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: glowPink, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 18, color: fg),
                          const SizedBox(width: 6),
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: dot,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black26, width: 1),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more, size: 18, color: fg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openPicker(
    BuildContext ctx, WidgetRef ref, int? currentId,
  ) async {
    final repo = ref.read(foldersRepoProvider);
    final folders = await repo.watchAll().first;
    final colors = ref.read(folderColorsProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int,int?>{});

    final selected = currentId ?? -1; // -1 = Sem pasta

    final chosen = await showModalBottomSheet<int?>(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (sheetCtx) {
        final kb = MediaQuery.of(sheetCtx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: kb),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12)),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1720).withOpacity(.90),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: glowCyan.withOpacity(.55)),
                    boxShadow: [
                      BoxShadow(color: glowPink.withOpacity(.20), blurRadius: 24),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                        const Text(
                        'Escolhe a pasta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                        ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            _neonTile(
                              sheetCtx,
                              title: 'Sem pasta',
                              color: Theme.of(ctx).colorScheme.outlineVariant,
                              selected: selected == -1,
                              value: -1,
                            ),
                            ...folders.map((f) {
                              final c = Color(colors[f.id] ??
                                  Theme.of(ctx).colorScheme.outlineVariant.value);
                              return _neonTile(
                                sheetCtx,
                                title: f.name,
                                color: c,
                                selected: selected == f.id,
                                value: f.id,
                              );
                            }),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosen == null) return;
    ref.read(editorProvider.notifier).setFolderId(chosen == -1 ? null : chosen);
  }

  /// Tile com dot da cor da pasta, glow leve quando selecionado.
  Widget _neonTile(
    BuildContext ctx, {
    required String title,
    required Color color,
    required bool selected,
    required int value,
  }) {
    return InkWell(
      onTap: () => Navigator.of(ctx).pop(value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : Colors.white24, width: 1.2),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(.35), blurRadius: 12)]
              : const [],
          color: const Color(0xFF0A1119),
        ),
        child: Row(
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: color, shape: BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? color : Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// lib/features/home/widgets/folder_chips_wrap.dart

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/home/providers/filters.dart';
import 'package:notebox/features/home/providers/folder_colors.dart';
import 'package:notebox/features/home/widgets/confirm_new_folder.dart';

class FolderChipsWrap extends ConsumerWidget {
  const FolderChipsWrap({super.key});

  static const kFolderSoftColors = <int>[
    0xFFE53935,
    0xFFD81B60,
    0xFF8E24AA,
    0xFF5E35B1,
    0xFF3949AB,
    0xFF1E88E5,
    0xFF039BE5,
    0xFF00897B,
    0xFF43A047,
    0xFFFDD835,
    0xFFFB8C00,
    0xFFF4511E,
    0xFF6D4C41,
    0xFF757575,
    0xFF546E7A,
  ];

  int _pickRandomFolderColor(List<Folder> folders) {
    final used = <int>{
      for (final f in folders)
        if (f.color != null) f.color!,
    };

    final available = kFolderSoftColors.where((c) => !used.contains(c)).toList();
    final list = available.isNotEmpty ? available : kFolderSoftColors;

    list.shuffle();
    return list.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders$ = ref.watch(foldersRepoProvider).watchAll();
    final colorsMap = ref
        .watch(folderColorsProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int, int?>{});
    final sel = ref.watch(folderFilterProvider);
    final db = ref.watch(dbProvider);

    return StreamBuilder<List<Folder>>(
      stream: folders$,
      builder: (_, snap) {
        final folders = snap.data ?? const <Folder>[];
        final outline = Theme.of(context).colorScheme.outlineVariant;
        const neonPink = Color(0xFFEA00FF);

        Widget neonWrap({
          required bool selected,
          required Color glow,
          required Widget child,
        }) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: glow.withOpacity(.9),
                        blurRadius: 12,
                        blurStyle: BlurStyle.normal,
                      )
                    ]
                  : const [],
            ),
            child: child,
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 0,
              children: [
                // Todas
                neonWrap(
                  selected: sel is All,
                  glow: neonPink,
                  child: ChoiceChip(
                    label: const Text('Todas'),
                    selected: sel is All,
                    showCheckmark: false,
                    side: BorderSide(
                      color: sel is All ? neonPink : outline,
                      width: 1.8,
                    ),
                    onSelected: (_) =>
                        ref.read(folderFilterProvider.notifier).state = const All(),
                  ),
                ),

                // Pastas
                ...folders.map((f) {
                  final cInt = colorsMap[f.id];
                  final dot = cInt != null ? Color(cInt) : outline;
                  final selected = sel is ById && sel.id == f.id;
                  final neon = cInt != null ? Color(cInt) : neonPink;

                  return neonWrap(
                    selected: selected,
                    glow: neon,
                    child: ChoiceChip(
                      label: Text(f.name),
                      selected: selected,
                      showCheckmark: false,
                      side: BorderSide(
                        color: selected ? neon : outline,
                        width: 1.8,
                      ),
                      avatar: CircleAvatar(backgroundColor: dot, radius: 6),
                      onSelected: (_) => ref.read(folderFilterProvider.notifier).state = ById(f.id),
                    ),
                  );
                }),

                // Adicionar
                neonWrap(
                  selected: false,
                  glow: neonPink,
                  child: ChoiceChip(
                    label: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(opacity: 0, child: Text('Todas')),
                        Icon(Icons.add, size: 16.5),
                      ],
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 1),
                    selected: false,
                    showCheckmark: false,
                    side: BorderSide(color: outline, width: 1.2),
                    onSelected: (_) async {
                      final name = await confirmNewFolder(context);
                      if (name == null || name.trim().isEmpty) return;

                      final color = _pickRandomFolderColor(folders);

                      await db.into(db.folders).insert(
                            FoldersCompanion.insert(
                              name: name.trim(),
                              color: drift.Value(color),
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

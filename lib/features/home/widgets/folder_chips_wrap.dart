import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/home/providers/filters.dart';
import 'package:notebox/features/home/providers/folder_colors.dart';

class FolderChipsWrap extends ConsumerWidget {
  const FolderChipsWrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders$ = ref.watch(foldersRepoProvider).watchAll();
    final colorsMap = ref
        .watch(folderColorsProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int, int?>{});
    final sel = ref.watch(folderFilterProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outlineColor = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15);

    BorderSide selectedSide(FolderFilter f) =>
        sel.runtimeType == f.runtimeType &&
                (f is! ById || (sel is ById && sel.id == f.id))
            ? BorderSide(color: isDark ? Colors.white : Colors.black, width: 1.2)
            : BorderSide(color: outlineColor, width: 1);

    return StreamBuilder<List<Folder>>(
      stream: folders$,
      builder: (_, snap) {
        final folders = snap.data ?? const <Folder>[];

        return Wrap(
          spacing: 4,
          runSpacing: 0,
          children: [
            ChoiceChip(
              label: const Text('Todas'),
              selected: sel is All,
              showCheckmark: false,
              side: selectedSide(const All()),
              onSelected: (_) =>
                  ref.read(folderFilterProvider.notifier).state = const All(),
            ),
            ...folders.map(
              (f) {
                final cInt = colorsMap[f.id];
                final color = cInt != null
                    ? Color(cInt)
                    : Theme.of(context).colorScheme.outlineVariant;

                return ChoiceChip(
                  label: Text(f.name),
                  selected: sel is ById && sel.id == f.id,
                  showCheckmark: false,
                  side: selectedSide(ById(f.id)),
                  avatar: CircleAvatar(
                    backgroundColor: color,
                    radius: 6,
                  ),
                  onSelected: (_) => ref
                      .read(folderFilterProvider.notifier)
                      .state = ById(f.id),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
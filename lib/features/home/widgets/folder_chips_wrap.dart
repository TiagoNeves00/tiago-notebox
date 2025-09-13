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

    BorderSide selectedSide(FolderFilter f) =>
        sel.runtimeType == f.runtimeType &&
                (f is! ById || (sel is ById && sel.id == f.id))
            ? const BorderSide(color: Colors.black87, width: 1.6)
            : BorderSide.none;

    return StreamBuilder<List<Folder>>(
      stream: folders$,
      builder: (_, snap) {
        final folders = snap.data ?? const <Folder>[];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todas'),
              selected: sel is All,
              showCheckmark: false,
              side: selectedSide(const All()),
              onSelected: (_) =>
                  ref.read(folderFilterProvider.notifier).state = const All(),
            ),
            ChoiceChip(
              label: const Text('Sem pasta'),
              selected: sel is Unfiled,
              showCheckmark: false,
              side: selectedSide(const Unfiled()),
              onSelected: (_) => ref
                  .read(folderFilterProvider.notifier)
                  .state = const Unfiled(),
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
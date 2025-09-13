import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/home/providers/filters.dart';
import 'package:notebox/features/home/providers/folder_colors.dart';

class FolderChipsWrap extends ConsumerWidget {
  const FolderChipsWrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(foldersRepoProvider).watchAll();
    final selected = ref.watch(selectedFolderIdProvider);

    final colorsMap = ref.watch(folderColorsProvider).maybeWhen(
      data: (m) => m,
      orElse: () => const <int, int?>{},
    );

    return StreamBuilder(
      stream: stream,
      builder: (_, snap) {
        final items = snap.data ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: selected == null,
                onSelected: (_) =>
                    ref.read(selectedFolderIdProvider.notifier).state = null,
              ),
              ...items.map(
                (f) => ChoiceChip(
                  label: Text(f.name),
                  selected: selected == f.id,
                  selectedColor: (colorsMap[f.id] != null
                      ? Color(colorsMap[f.id]!).withOpacity(.35)
                      : Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withOpacity(.35)),
                  avatar: colorsMap[f.id] != null
                      ? CircleAvatar(
                          radius: 6,
                          backgroundColor: Color(colorsMap[f.id]!),
                        )
                      : null,
                  onSelected: (_) =>
                      ref.read(selectedFolderIdProvider.notifier).state = f.id,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

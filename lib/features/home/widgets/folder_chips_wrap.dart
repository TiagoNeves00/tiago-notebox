import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/home/providers/filters.dart';
import 'package:notebox/features/home/widgets/note_grid.dart';

class FolderChipsWrap extends ConsumerWidget {
  const FolderChipsWrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(foldersRepoProvider).watchAll();
    final selected = ref.watch(selectedFolderIdProvider);

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
                onSelected: (_) => ref.read(selectedFolderIdProvider.notifier).state = null,
              ),
              ...items.map((f) => ChoiceChip(
                    label: Text(f.name),
                    selected: selected == f.id,
                    selectedColor: folderColor(f.id).withOpacity(.4),
                    onSelected: (_) => ref.read(selectedFolderIdProvider.notifier).state = f.id,
                  )),
            ],
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/features/home/providers/folder_colors.dart';
import 'package:notebox/features/home/widgets/note_card.dart';

class NoteGrid extends ConsumerWidget {
  final List<Note> notes;
  const NoteGrid({super.key, required this.notes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorsMap = ref.watch(folderColorsProvider).maybeWhen(
          data: (m) => m,
          orElse: () => const <int, int?>{},
        );

    Color resolveColor(Note n) {
      if (n.color != null) return Color(n.color!);
      final c = n.folderId != null ? colorsMap[n.folderId!] : null;
      return c != null
          ? Color(c)
          : Theme.of(context).colorScheme.outlineVariant;
    }

    if (notes.isEmpty) return const Center(child: Text('Sem notas'));

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
      ),
      itemCount: notes.length,
      itemBuilder: (_, i) {
        final n = notes[i];
        return NoteCard(
          key: ValueKey(n.id),
          note: n,
          color: resolveColor(n),
          onTap: () => context.push('/edit/${n.id}'),
        );
      },
    );
  }
}

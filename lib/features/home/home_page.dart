import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/dev/dev_seed.dart';
import 'package:notebox/features/home/providers/filters.dart';
import 'package:notebox/features/home/providers/notes_provider.dart';
import 'package:notebox/features/home/widgets/folder_carousel.dart';
import 'package:notebox/theme/theme_mode.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteBox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.bolt),
            tooltip: 'DEV seed',
            onPressed: () => runDevSeed(ref, force: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          const FolderCarousel(),
          const SizedBox(height: 8),

          const _FoldersChips(),
          const SizedBox(height: 8),

          Expanded(
            child: ref
                .watch(notesProvider)
                .when(
                  data: (notes) {
                    if (notes.isEmpty) {
                      return const Center(child: Text('Sem notas ainda'));
                    }
                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (_, i) {
                        final n = notes[i];
                        final c = n.color != null
                            ? Color(n.color!)
                            : Theme.of(context).colorScheme.outlineVariant;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: c, width: 1.5),
                          ),
                          child: InkWell(
                            onTap: () => context.push('/edit/${n.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.body,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/edit'),
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
  }
}

class _FoldersChips extends ConsumerWidget {
  const _FoldersChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(foldersRepoProvider).watchAll();
    final sel = ref.watch(selectedFolderIdProvider);
    return SizedBox(
      height: 40,
      child: StreamBuilder<List<Folder>>(
        stream: stream,
        builder: (context, snap) {
          final items = snap.data ?? const <Folder>[];
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: const Text('Todas'),
                  selected: sel == null,
                  onSelected: (_) =>
                      ref.read(selectedFolderIdProvider.notifier).state = null,
                ),
              ),
              for (final f in items)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(f.name),
                    selected: sel == f.id,
                    onSelected: (_) =>
                        ref.read(selectedFolderIdProvider.notifier).state =
                            f.id,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

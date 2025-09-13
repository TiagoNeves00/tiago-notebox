import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/features/editor/editor_baseline.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/home/providers/notes_provider.dart';
import 'package:notebox/features/home/widgets/folder_chips_wrap.dart';
import 'package:notebox/features/home/widgets/note_grid.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),

          // Chips de pastas em multi-linha
          const FolderChipsWrap(),
          const SizedBox(height: 8),

          // Conteúdo
          Expanded(
            child: ref
                .watch(notesProvider)
                .when(
                  data: (notes) => notes.isEmpty
                      ? const Center(child: Text('Sem notas'))
                      : NoteGrid(notes: notes), // grelha com outline por cor
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          onPressed: () {
        // reset estado do editor para draft vazio
        ref.read(editorProvider.notifier).load(NoteDraft());
        ref.read(editorBaselineProvider.notifier).state = NoteDraft();
        context.push('/edit'); // sem id = novo
          },
          backgroundColor: const Color.fromARGB(255, 234, 0, 255),
          shape: CircleBorder(
        side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          width: 1.5,
        ),
          ),
          child: const Icon(Icons.add, size: 36, color: Colors.white),
        ),
      ),
    );
  }
}

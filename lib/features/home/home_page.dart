import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/features/home/providers/view_mode.dart';
import 'package:notebox/features/home/widgets/folder_carousel.dart';
import 'package:notebox/features/home/widgets/note_list_mock.dart';
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
            icon: Icon(ref.watch(gridModeProvider) ? Icons.view_list : Icons.grid_view),
            onPressed: () => ref.read(gridModeProvider.notifier).state =
              !ref.read(gridModeProvider),
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
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Chip(label: Text('All'))),
                Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Chip(label: Text('Work'))),
                Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Chip(label: Text('Personal'))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const FolderCarousel(),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: NoteListMock(
                key: ValueKey(ref.watch(gridModeProvider)),
                grid: ref.watch(gridModeProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
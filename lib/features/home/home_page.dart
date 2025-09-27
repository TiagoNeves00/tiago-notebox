// HomePage com divisor horizontal pink clean entre pastas e notas.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/features/home/providers/notes_provider.dart';
import 'package:notebox/features/home/widgets/folder_chips_wrap.dart';
import 'package:notebox/features/home/widgets/modern_fab.dart';
import 'package:notebox/features/home/widgets/note_grid.dart';

final _searchVisibleProvider = StateProvider<bool>((_) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSearch = ref.watch(_searchVisibleProvider);
    const _h = 84.0; // altura barra aberta

    Widget searchBar() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          height: showSearch ? _h : 12, // margem quando fechado
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: showSearch ? 1 : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                opacity: showSearch ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon:
                          const Icon(Icons.search, size: 18, color: Color(0xFF9FB7CB)),
                      filled: true,
                      fillColor: const Color(0xFF0E1720).withOpacity(.55),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0x3300F5FF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0x3300F5FF)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00F5FF)),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onChanged: (v) =>
                        ref.read(searchQueryProvider.notifier).state = v,
                  ),
                ),
              ),
            ),
          ),
        );

    return Scaffold(
      body: Column(
        children: [
          searchBar(),
          const FolderChipsWrap(),
          const SizedBox(height: 8),

          // --- Divisor pink clean (neon leve e fino) ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 42, vertical: 12),
            child: _NeonDivider(),
          ),

          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (n) {
                final dir = n.direction;
                if (dir == ScrollDirection.forward && !showSearch) {
                  ref.read(_searchVisibleProvider.notifier).state = true;
                } else if (dir == ScrollDirection.reverse && showSearch) {
                  ref.read(_searchVisibleProvider.notifier).state = false;
                }
                return false;
              },
              child: ref.watch(notesProvider).when(
                    data: (notes) =>
                        notes.isEmpty ? const Center(child: Text('Sem notas')) : NoteGrid(notes: notes),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erro: $e')),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: ModernFab(onCreate: () => context.push('/edit')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Linha “dupla” com bolinha central, estilo neon pink.
class _NeonDivider extends StatelessWidget {
  const _NeonDivider();

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFEA00FF);

    Widget _line() => Container(
          height: 1,
          decoration: BoxDecoration(
            color: pink,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(color: Color(0xFFEA00FF), blurRadius: 3),
            ],
          ),
        );

    Widget _dot() => Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEA00FF),
            boxShadow: [
              BoxShadow(color:  Color(0xFFEA00FF), blurRadius: 8),
            ],
          ),
        );

    return SizedBox(
      height: 16, // espaço vertical confortável
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _line()),
          const SizedBox(width: 10),
          _dot(),
          const SizedBox(width: 10),
          Expanded(child: _line()),
        ],
      ),
    );
  }
}


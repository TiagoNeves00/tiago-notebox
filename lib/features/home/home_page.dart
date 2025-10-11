// lib/features/home/home_page.dart
// HomePage com search neon, clear "x", chips que desaparecem com query
// e divisor neon FIXO no topo da lista (sem “buraco” ao fazer scroll).


import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/features/home/providers/notes_provider.dart';
import 'package:notebox/features/home/widgets/folder_chips_wrap.dart';
import 'package:notebox/features/home/widgets/modern_fab.dart';
import 'package:notebox/features/home/widgets/neon_divider_rotating.dart';
import 'package:notebox/features/home/widgets/note_grid.dart';

final _searchVisibleProvider = StateProvider<bool>((_) => false);

// Controller ligado ao provider para limpar o campo por código.
final _searchControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final c = TextEditingController(text: ref.read(searchQueryProvider));
  ref.onDispose(c.dispose);
  ref.listen<String>(searchQueryProvider, (prev, next) {
    if (c.text != next) {
      c.value = c.value.copyWith(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  });
  return c;
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _kDividerHeight = 22.0; // espaço reservado para o divisor
  static const _kDividerHPad = 42.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSearch = ref.watch(_searchVisibleProvider);
    final query = ref.watch(searchQueryProvider);
    final hasQuery = query.trim().isNotEmpty;

    Widget searchBar() {
      final ctrl = ref.watch(_searchControllerProvider);
      const h = 84.0, pink = Color(0xFFEA00FF);
      final outline = Theme.of(context).colorScheme.outlineVariant;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        height: showSearch ? h : 22,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: showSearch ? 1 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              opacity: showSearch ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 14),
                child: Center(
                  child: SizedBox(
                    height: 60,
                    width: MediaQuery.sizeOf(context).width * 0.85,
                    child: Focus(
                      onFocusChange: (_) =>
                          (context as Element).markNeedsBuild(),
                      child: Builder(
                        builder: (ctx) {
                          final focused = Focus.of(ctx).hasFocus;
                          return Container(
                            // GLOW externo
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: focused
                                  ? [
                                      BoxShadow(
                                        color: pink.withOpacity(.35),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : const [],
                            ),
                            child: Container(
                              // BORDA + fundo
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color(0xFF0A1119),
                                border: Border.all(
                                  color: focused ? pink : outline,
                                  width: 1.2,
                                ),
                              ),
                              child: TextField(
                                controller: ctrl,
                                cursorColor: pink,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search notes...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(.85),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Color(0xFF9FB7CB),
                                  ),
                                  suffixIcon: hasQuery
                                      ? IconButton(
                                          tooltip: 'Limpar',
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            ref
                                                    .read(
                                                      searchQueryProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                '';
                                            ctrl.clear();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 18,
                                  ),
                                ),
                                onChanged: (v) =>
                                    ref
                                            .read(searchQueryProvider.notifier)
                                            .state =
                                        v,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (n) {
          final dir = n.direction;
          if (dir == ScrollDirection.forward && !showSearch) {
            ref.read(_searchVisibleProvider.notifier).state = true;
          } else if (dir == ScrollDirection.reverse && showSearch) {
            ref.read(_searchVisibleProvider.notifier).state = false;
          }
          return false;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              
              searchBar(),

              if (ref.watch(_searchVisibleProvider)) const SizedBox(height: 12), // ↑ ajusta aqui


              // Chips desaparecem quando há query
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: hasQuery
                    ? const SizedBox.shrink()
                    : const Column(
                        key: ValueKey('filters'),
                        children: [FolderChipsWrap(), SizedBox(height: 8)],
                      ),
              ),

              const SizedBox(height: 12),

              // Lista de notas com divisor FIXO por cima
              Expanded(
                child: Stack(
                  children: [
                    // Lista colada ao topo
                    ref
                        .watch(notesProvider)
                        .when(
                          data: (notes) => notes.isEmpty
                              ? const Center(child: Text('Sem notas'))
                              : const NoteGridWrapper(), // ver abaixo
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Erro: $e')),
                        ),

                    if (!hasQuery) ...[
                      // Header opaco que recorta a lista
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 10, // mesma altura do divisor
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface, // fundo da página
                            ),
                          ),
                        ),
                      ),
                      // Divisor por cima do header
                      const Positioned(
                        top: 0,
                        left: 22,
                        right: 22,
                        child: IgnorePointer(child: FlowNeonDivider()),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      floatingActionButton: ModernFab(onCreate: () => context.push('/edit')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class NoteGridWrapper extends ConsumerWidget {
  const NoteGridWrapper({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider).value!;
    return NoteGrid(
      notes: notes,
    ); // NoteGrid já com padding: EdgeInsets.fromLTRB(12, 0, 12, 12)
  }
}

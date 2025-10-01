// lib/features/home/home_page.dart
// HomePage com search neon, clear "x" que limpa mesmo o campo,
// esconder chips+divider quando há texto e transições suaves.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/features/home/providers/notes_provider.dart';
import 'package:notebox/features/home/widgets/folder_chips_wrap.dart';
import 'package:notebox/features/home/widgets/modern_fab.dart';
import 'package:notebox/features/home/widgets/note_grid.dart';

final _searchVisibleProvider = StateProvider<bool>((_) => false);

// Controller ligado ao provider para podermos limpar o campo por código.
final _searchControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSearch = ref.watch(_searchVisibleProvider);
    final query = ref.watch(searchQueryProvider);
    final hasQuery = query.trim().isNotEmpty;

    Widget searchBar() {
      const pink = Color(0xFFEA00FF);
      final outline = Theme.of(context).colorScheme.outlineVariant;
      const _h = 84.0;
      final ctrl = ref.watch(_searchControllerProvider);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        height: showSearch ? _h : 22,
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
                child: Center(
                  child: SizedBox(
                    height: 60,
                    width: MediaQuery.sizeOf(context).width * 0.85,
                    child: Focus(
                      onFocusChange: (_) => (context as Element).markNeedsBuild(),
                      child: Builder(builder: (ctx) {
                        final focused = Focus.of(ctx).hasFocus;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: focused ? pink : outline,
                                width: 1.2,
                              ),
                              boxShadow: focused
                                  ? [BoxShadow(color: pink.withOpacity(.35), blurRadius: 12)]
                                  : const [],
                              color: const Color(0xFF0A1119),
                            ),
                            child: TextField(
                              controller: ctrl,
                              cursorColor: pink,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search notes...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(.85)),
                                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9FB7CB)),
                                // Botão limpar: limpa provider + controller + desfoca
                                suffixIcon: hasQuery
                                    ? IconButton(
                                        tooltip: 'Limpar',
                                        icon: const Icon(Icons.close, size: 18, color: Colors.white),
                                        onPressed: () {
                                          ref.read(searchQueryProvider.notifier).state = '';
                                          ctrl.clear(); // <- limpa 100% o campo
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 18, // texto centrado verticalmente
                                ),
                              ),
                              onChanged: (v) =>
                                  ref.read(searchQueryProvider.notifier).state = v,
                            ),
                          ),
                        );
                      }),
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
              // Esconde chips+divider quando há texto na busca
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: hasQuery ? const SizedBox.shrink() : const _FiltersAndDivider(),
              ),
              Expanded(
                child: ref.watch(notesProvider).when(
                      data: (notes) =>
                          notes.isEmpty ? const Center(child: Text('Sem notas')) : NoteGrid(notes: notes),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Erro: $e')),
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ModernFab(onCreate: () => context.push('/edit')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _FiltersAndDivider extends StatelessWidget {
  const _FiltersAndDivider();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('filters'),
      children: const [
        FolderChipsWrap(),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 42, vertical: 12),
          child: _NeonDivider(),
        ),
      ],
    );
  }
}

/// Linha “dupla” com bolinha central, estilo neon pink.
class _NeonDivider extends StatelessWidget {
  const _NeonDivider();

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFEA00FF);
    Widget line() => Container(
          height: 1,
          decoration: BoxDecoration(
            color: pink,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [BoxShadow(color: Color(0xFFEA00FF), blurRadius: 3)],
          ),
        );
    Widget dot() => Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEA00FF),
            boxShadow: [BoxShadow(color: Color(0xFFEA00FF), blurRadius: 8)],
          ),
        );
    return SizedBox(
      height: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: line()),
          const SizedBox(width: 10),
          dot(),
          const SizedBox(width: 10),
          Expanded(child: line()),
        ],
      ),
    );
  }
}

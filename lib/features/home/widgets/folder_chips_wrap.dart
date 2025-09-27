import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/home/providers/filters.dart';
import 'package:notebox/features/home/providers/folder_colors.dart';
import 'package:notebox/features/home/widgets/neon_action_button.dart';

class FolderChipsWrap extends ConsumerWidget {
  const FolderChipsWrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders$ = ref.watch(foldersRepoProvider).watchAll();
    final colorsMap = ref
        .watch(folderColorsProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int, int?>{});
    final sel = ref.watch(folderFilterProvider);
    final db = ref.watch(dbProvider);

    // Neon sheet (sobe com teclado)
    Future<String?> _editName(BuildContext ctx, [String initial = '']) async {
      final tc = TextEditingController(text: initial);
      const c1 = Color(0xFFEA00FF), c2 = Color(0xFF00F5FF);
      return showModalBottomSheet<String>(
        context: ctx,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        showDragHandle: true,
        builder: (bctx) {
          final mq = MediaQuery.of(bctx);
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: mq.viewInsets,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Material(
                  color: const Color(0xFF0E1720).withOpacity(.90),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('Nova pasta',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: tc,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nome da pasta',
                          labelStyle: const TextStyle(color: Color(0xFFAED2FF)),
                          filled: true,
                          fillColor: const Color(0xFF0A1119),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: c2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: c1, width: 1.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: tc,
                        builder: (_, v, __) => SizedBox(
                          width: double.infinity,
                          child: NeonActionButton(
                            icon: Icons.check,
                            label: 'Guardar',
                            enabled: v.text.trim().isNotEmpty,
                            onPressed: () => Navigator.of(bctx, rootNavigator: true)
                                .pop(tc.text.trim()),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return StreamBuilder<List<Folder>>(
      stream: folders$,
      builder: (_, snap) {
        final folders = snap.data ?? const <Folder>[];
        final outline = Theme.of(context).colorScheme.outlineVariant;
        const neonPink = Color(0xFFEA00FF);

        Widget neonWrap({required bool selected, required Color glow, required Widget child}) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(vertical: 1), // reduced vertical margin
            decoration: BoxDecoration(
              boxShadow: selected
                  ? [BoxShadow(color: glow.withOpacity(.35), blurRadius: 12)]
                  : const [],
            ),
            child: child,
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 4,   // reduced horizontal spacing
              runSpacing: 0, // reduced vertical spacing
              children: [
                // Todas
                neonWrap(
                  selected: sel is All,
                  glow: neonPink,
                  child: ChoiceChip(
                    label: const Text('Todas'),
                    selected: sel is All,
                    showCheckmark: false,
                    side: BorderSide(color: sel is All ? neonPink : outline, width: 1.2),
                    onSelected: (_) =>
                        ref.read(folderFilterProvider.notifier).state = const All(),
                  ),
                ),

                // Pastas
                ...folders.map((f) {
                  final cInt = colorsMap[f.id];
                  final dot = cInt != null ? Color(cInt) : outline;
                  final selected = sel is ById && sel.id == f.id;
                  final neon = cInt != null ? Color(cInt) : neonPink;

                  return neonWrap(
                    selected: selected,
                    glow: neon,
                    child: ChoiceChip(
                      label: Text(f.name),
                      selected: selected,
                      showCheckmark: false,
                      side: BorderSide(color: selected ? neon : outline, width: 1.2),
                      avatar: CircleAvatar(backgroundColor: dot, radius: 6),
                      onSelected: (_) =>
                          ref.read(folderFilterProvider.notifier).state = ById(f.id),
                    ),
                  );
                }),

                // Adicionar
                ChoiceChip(
                  label: const Text(''),
                  selected: false,
                  showCheckmark: false,
                  side: BorderSide(color: outline, width: 1.2),
                  avatar: const Icon(Icons.add, size: 22),
                  onSelected: (_) async {
                    final name = await _editName(context, '');
                    if (name == null || name.isEmpty) return;
                    await db.into(db.folders).insert(FoldersCompanion.insert(name: name));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

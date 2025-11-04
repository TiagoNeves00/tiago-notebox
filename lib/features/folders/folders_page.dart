/// FoldersPage — menus “Editar nome / Nova pasta” como bottom sheet neon (desliza de baixo).
/// Mantém o botão "Nova pasta" escondido enquanto o sheet está aberto.
library;

import 'dart:ui';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/folders/note_counts_provider.dart';
import 'package:notebox/features/home/widgets/confirm_deleted_folder.dart';
import 'package:notebox/features/home/widgets/neon_action_button.dart';
import 'package:notebox/features/home/widgets/neon_icon_button.dart';

final foldersEditDialogOpenProvider = StateProvider<bool>((_) => false);

class FoldersPage extends ConsumerWidget {
  const FoldersPage({super.key});

  static const kFolderSoftColors = <int>[
    0xFFE53935,
    0xFFD81B60,
    0xFF8E24AA,
    0xFF5E35B1,
    0xFF3949AB,
    0xFF1E88E5,
    0xFF039BE5,
    0xFF00897B,
    0xFF43A047,
    0xFFFDD835,
    0xFFFB8C00,
    0xFFF4511E,
    0xFF6D4C41,
    0xFF757575,
    0xFF546E7A,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(foldersRepoProvider).watchAll();
    final db = ref.watch(dbProvider);
    final counts = ref
        .watch(noteCountsByFolderProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int, int>{});
    final editOpen = ref.watch(foldersEditDialogOpenProvider);

    Future<String?> editNameSheet(BuildContext context, [String initial = '']) async {
      final tc = TextEditingController(text: initial);
      const c1 = Color(0xFFEA00FF), c2 = Color(0xFF00F5FF);

      ref.read(foldersEditDialogOpenProvider.notifier).state = true;
      try {
        return await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          showDragHandle: true,
          builder: (ctx) {
            final mq = MediaQuery.of(ctx);
            return AnimatedPadding(
              padding: mq.viewInsets,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Material(
                    color: const Color(0xFF0E1720).withOpacity(.90),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Row(children: [
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Nova pasta',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Fechar',
                            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(null),
                            icon: const Icon(Icons.close, color: Colors.white70),
                          ),
                        ]),
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
                              onPressed: () =>
                                  Navigator.of(ctx, rootNavigator: true).pop(tc.text.trim()),
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
      } finally {
        ref.read(foldersEditDialogOpenProvider.notifier).state = false;
      }
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Folder>>(
            stream: stream,
            builder: (_, snap) {
              final items = snap.data ?? [];
              if (items.isEmpty) return const Center(child: Text('Sem pastas'));
              final foldersStream = ref.watch(foldersRepoProvider).watchAll();
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final f = items[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 4), // 🔹 margem superior maior
                    title: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 18, // 🔹 nome maior
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                              children: [
                                TextSpan(text: f.name),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '(${counts[f.id] ?? 0})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall, // 🔹 voltou ao original
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            final folders = await foldersStream.first;
                            final used = <int>{
                              for (final x in folders)
                                if (x.color != null && x.id != f.id) x.color!,
                            };
                            final picked = await showModalBottomSheet<int>(
                              context: context,
                              showDragHandle: true,
                              builder: (_) => GridView.count(
                                crossAxisCount: 4,
                                padding: const EdgeInsets.all(16),
                                shrinkWrap: true,
                                children: kFolderSoftColors.map((v) {
                                  final isUsed = used.contains(v);
                                  return Opacity(
                                    opacity: isUsed ? 0.35 : 1,
                                    child: InkWell(
                                      onTap: isUsed ? null : () => Navigator.pop(context, v),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Color(v),
                                              radius: 18,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.black.withOpacity(0.15),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (f.color == v)
                                              const Icon(Icons.check, size: 18, color: Colors.white),
                                            if (isUsed && f.color != v)
                                              const Icon(Icons.block, size: 18, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                            if (picked != null && picked != f.color) {
                              await (db.update(db.folders)..where((t) => t.id.equals(f.id))).write(
                                FoldersCompanion(color: drift.Value(picked)),
                              );
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: f.color != null
                                  ? Color(f.color!)
                                  : Theme.of(context).colorScheme.outlineVariant,
                              border: Border.all(color: Colors.black.withOpacity(0.15), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 34),
                        NeonIconButton(
                          icon: Icons.edit,
                          tooltip: 'Renomear',
                          glow: const Color(0xFFEA00FF),
                          onPressed: () async {
                            final name = await editNameSheet(context, f.name);
                            if (name == null || name.isEmpty) return;
                            await (db.update(db.folders)..where((t) => t.id.equals(f.id))).write(
                              FoldersCompanion(name: drift.Value(name)),
                            );
                          },
                        ),
                        const SizedBox(width: 14),
                        NeonIconButton(
                          icon: Icons.delete,
                          tooltip: 'Eliminar',
                          glow: const Color(0xFFEA00FF),
                          onPressed: () async {
                            final ok = await confirmDeleteFolder(context);
                            if (!ok) return;

                            await db.transaction(() async {
                              await (db.update(db.notes)..where((t) => t.folderId.equals(f.id)))
                                  .write(const NotesCompanion(folderId: drift.Value(null)));
                              await (db.delete(db.folders)..where((t) => t.id.equals(f.id))).go();
                            });

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(const SnackBar(
                                content: Text(
                                  'Pasta eliminada. Notas foram para "Sem pasta".',
                                ),
                              ));
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (!editOpen)
          Padding(
            padding: const EdgeInsets.all(32),
            child: NeonActionButton(
              icon: Icons.add,
              label: 'Nova pasta',
              onPressed: () async {
                final name = await editNameSheet(context, '');
                if (name == null || name.isEmpty) return;
                await db.into(db.folders).insert(FoldersCompanion.insert(name: name));
              },
            ),
          ),
      ],
    );
  }
}

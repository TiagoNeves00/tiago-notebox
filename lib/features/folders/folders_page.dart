// lib/features/folders/folders_page.dart

import 'dart:ui';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    0xFFE53935, 0xFFD81B60, 0xFF8E24AA, 0xFF5E35B1, 0xFF3949AB,
    0xFF1E88E5, 0xFF039BE5, 0xFF00897B, 0xFF43A047, 0xFFFDD835,
    0xFFFB8C00, 0xFFF4511E, 0xFF6D4C41, 0xFF757575, 0xFF546E7A,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(foldersRepoProvider).watchAll();
    final db = ref.watch(dbProvider);
    final counts = ref.watch(noteCountsByFolderProvider).maybeWhen(
          data: (m) => m,
          orElse: () => const <int, int>{},
        );
    final editOpen = ref.watch(foldersEditDialogOpenProvider);

    // -------------------------
    //  Scaffold + AppBar centrado
    // -------------------------
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Pastas"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/notes'),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Folder>>(
              stream: stream,
              builder: (_, snap) {
                final items = snap.data ?? [];

                if (items.isEmpty) {
                  return const Center(child: Text('Sem pastas'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final f = items[i];

                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${f.name}  (${counts[f.id] ?? 0})",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cor da pasta
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: f.color != null
                                  ? Color(f.color!)
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                              border: Border.all(
                                color: Colors.black.withOpacity(0.15),
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 44),

                          // Editar pasta
                          NeonIconButton(
                            icon: Icons.edit,
                            glow: const Color(0xFF00F5FF),
                            tooltip: "Renomear",
                            onPressed: () async {
                              final name =
                                  await _editNameSheet(context, ref, f.name);
                              if (name == null || name.isEmpty) return;

                              await (db.update(db.folders)
                                    ..where((t) => t.id.equals(f.id)))
                                  .write(
                                FoldersCompanion(name: drift.Value(name)),
                              );
                            },
                          ),

                          const SizedBox(width: 14),

                          // Remover pasta
                          IconButton(
                            icon: Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEA00FF)
                                      .withOpacity(.35),
                                  blurRadius: 12,
                                ),
                              ]),
                              child: const Icon(Icons.delete),
                            ),
                            onPressed: () async {
                              final ok = await confirmDeleteFolder(context);
                              if (!ok) return;

                              // Remover + mover notas
                              await db.transaction(() async {
                                await (db.update(db.notes)
                                      ..where((t) => t.folderId.equals(f.id)))
                                    .write(const NotesCompanion(
                                        folderId: drift.Value(null)));

                                await (db.delete(db.folders)
                                      ..where((t) => t.id.equals(f.id)))
                                    .go();
                              });

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                ..clearSnackBars()
                                ..showSnackBar(const SnackBar(
                                    content: Text(
                                        'Pasta eliminada. Notas movidas para "Sem pasta".')));
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

          // Botão Nova Pasta — escondido quando o sheet está aberto
          if (!editOpen)
            Padding(
              padding: const EdgeInsets.all(32),
              child: NeonActionButton(
                icon: Icons.add,
                label: 'Nova pasta',
                onPressed: () async {
                  final name = await _editNameSheet(context, ref, "");
                  if (name == null || name.isEmpty) return;

                  await db
                      .into(db.folders)
                      .insert(FoldersCompanion.insert(name: name));
                },
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------
  //  Bottom Sheet de editar/criar pasta
  // -------------------------
  Future<String?> _editNameSheet(
      BuildContext context, WidgetRef ref, String initial) async {
    final tc = TextEditingController(text: initial);

    ref.read(foldersEditDialogOpenProvider.notifier).state = true;

    try {
      return await showModalBottomSheet<String>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final mq = MediaQuery.of(ctx);

          return AnimatedPadding(
            padding: mq.viewInsets,
            duration: const Duration(milliseconds: 180),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Material(
                color: const Color(0xFF0E1720).withOpacity(.90),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Nova pasta",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),

                      // Campo de texto
                      TextField(
                        controller: tc,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Nome da pasta",
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF0A1119),
                        ),
                      ),

                      const SizedBox(height: 18),

                      NeonActionButton(
                        icon: Icons.check,
                        label: "Guardar",
                        enabled: tc.text.trim().isNotEmpty,
                        onPressed: () =>
                            Navigator.of(ctx).pop(tc.text.trim()),
                      ),
                    ],
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
}

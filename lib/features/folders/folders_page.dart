import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/folders_repo.dart';

class FoldersPage extends ConsumerWidget {
  const FoldersPage({super.key});
  static const kFolderSoftColors = <int>[
    0xFFFDE68A, // amarelo suave
    0xFFBFDBFE, // azul claro
    0xFFC7D2FE, // indigo claro
    0xFFDDD6FE, // roxo claro
    0xFFA7F3D0, // teal/verde menta
    0xFFFEF3C7, // creme
    0xFFFBCFE8, // rosa claro
    0xFFBAE6FD, // ciano claro
    0xFFD9F99D, // lima suave
    0xFFFFE4E6, // rosa pálido
    0xFFFFEDD5, // pêssego
    0xFFE9D5FF, // lilás
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(foldersRepoProvider).watchAll();
    final db = ref.watch(dbProvider);

    Future<String?> editName([String initial = '']) async {
      final tc = TextEditingController(text: initial);
      return showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tc,
                decoration: const InputDecoration(labelText: 'Nome da pasta'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context, tc.text.trim()),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      );
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
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final f = items[i];
                  return ListTile(
                    title: Text(f.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            final folders = await foldersStream.first;
                            final used = <int>{
                              for (final x in folders)
                                if (x.color != null && x.id != f.id)
                                  x.color!, // cores de outras pastas
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
                                      onTap: isUsed
                                          ? null
                                          : () => Navigator.pop(context, v),
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
                                              const Icon(
                                                Icons.check,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            if (isUsed && f.color != v)
                                              const Icon(
                                                Icons.block,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                            if (picked != null && picked != f.color) {
                              await (db.update(
                                db.folders,
                              )..where((t) => t.id.equals(f.id))).write(
                                FoldersCompanion(color: drift.Value(picked)),
                              );
                            }
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: f.color != null
                                  ? Color(f.color!)
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                              border: Border.all(
                                color: Colors.black.withOpacity(0.15),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final name = await editName(f.name);
                            if (name == null || name.isEmpty) return;
                            await (db.update(
                              db.folders,
                            )..where((t) => t.id.equals(f.id))).write(
                              FoldersCompanion(name: drift.Value(name)),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await (db.delete(
                              db.folders,
                            )..where((t) => t.id.equals(f.id))).go();
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Nova pasta'),
            onPressed: () async {
              final name = await editName('');
              if (name == null || name.isEmpty) return;
              await db
                  .into(db.folders)
                  .insert(FoldersCompanion.insert(name: name));
            },
          ),
        ),
      ],
    );
  }
}

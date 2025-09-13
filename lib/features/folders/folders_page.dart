import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/folders_repo.dart';


class FoldersPage extends ConsumerWidget {
  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(foldersRepoProvider).watchAll();
    final db = ref.watch(dbProvider);

    Future<String?> editName([String initial = '']) async {
      final tc = TextEditingController(text: initial);
      return showModalBottomSheet<String>(
        context: context, showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: tc, decoration: const InputDecoration(labelText: 'Nome da pasta')),
            const SizedBox(height: 12),
            FilledButton(onPressed: ()=>Navigator.pop(context, tc.text.trim()), child: const Text('Guardar')),
          ]),
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
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final f = items[i];
                  return ListTile(
                    title: Text(f.name),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final name = await editName(f.name);
                          if (name==null || name.isEmpty) return;
                          await (db.update(db.folders)..where((t)=>t.id.equals(f.id)))
                            .write(FoldersCompanion(name: drift.Value(name)));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await (db.delete(db.folders)..where((t)=>t.id.equals(f.id))).go();
                        },
                      ),
                    ]),
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
              if (name==null || name.isEmpty) return;
              await db.into(db.folders).insert(FoldersCompanion.insert(name: name));
            },
          ),
        ),
      ],
    );
  }
}

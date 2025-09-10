import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/data/repos/revisions_repo.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final int? noteId;
  const NoteEditorPage({super.key, this.noteId});
  @override
  ConsumerState<NoteEditorPage> createState() => _S();
}

class _S extends ConsumerState<NoteEditorPage> {
  final _title = TextEditingController(), _body = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      final db = ref.read(dbProvider);
      Future(() async {
        final n = await (db.select(
          db.notes,
        )..where((t) => t.id.equals(widget.noteId!))).getSingle();

        ref
            .read(editorProvider.notifier)
            .load(
              NoteDraft(
                title: n.title,
                body: n.body,
                color: n.color,
                folderId: n.folderId,
              ),
            );

        setState(() {}); // força rebuild inicial
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    final st = ref.watch(editorProvider);
    final ctrl = ref.read(editorProvider.notifier);
    final foldersStream = ref.watch(foldersRepoProvider).watchAll();
    _title.value = _title.value.copyWith(
      text: st.title,
      selection: _title.selection,
    );
    _body.value = _body.value.copyWith(
      text: st.body,
      selection: _body.selection,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Nova nota' : 'Editar nota'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: ctrl.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: ctrl.redo),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _pickColor(c, ctrl),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final id = await ref
                  .read(notesRepoProvider)
                  .upsert(
                    id: widget.noteId,
                    title: st.title,
                    body: st.body,
                    color: st.color,
                    folderId: st.folderId,
                  );
              await ref
                  .read(revisionsRepoProvider)
                  .add(id, ctrl.snapshotJson());
              if (mounted) Navigator.pop(c);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            StreamBuilder(
              stream: foldersStream,
              builder: (c, snap) {
                final items = snap.data ?? [];
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: st.folderId,
                        hint: const Text('Seleciona pasta'),
                        items: items
                            .map(
                              (f) => DropdownMenuItem(
                                value: f.id,
                                child: Text(f.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          ctrl.set(
                            color: st.color,
                            title: st.title,
                            body: st.body,
                            folderId: v,
                          );
                          ctrl.set(folderId: v);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final name = await showModalBottomSheet<String>(
                          context: c,
                          builder: (_) {
                            final tc = TextEditingController();
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: tc,
                                    decoration: const InputDecoration(
                                      labelText: 'Nova pasta',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(c, tc.text.trim()),
                                    child: const Text('Criar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        if (name != null && name.isNotEmpty) {
                          // cria pasta e seleciona
                          final db = ref.read(dbProvider);
                          final id = await db
                              .into(db.folders)
                              .insert(FoldersCompanion.insert(name: name));
                          ctrl.set(folderId: id);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                hintText: 'Título',
                border: InputBorder.none,
              ),
              onChanged: (v) => ctrl.set(title: v),
            ),
            Expanded(
              child: TextField(
                controller: _body,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Escreve…',
                  border: InputBorder.none,
                ),
                onChanged: (v) => ctrl.set(body: v),
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.check_box_outlined),
                  label: const Text('Checklist'),
                  onPressed: () => _toggleChecklist(ctrl),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: st.color != null ? Color(st.color!) : null,
    );
  }

  void _toggleChecklist(EditorCtrl ctrl) {
    final t = ref.read(editorProvider).body;
    final lines = t.split('\n');
    if (lines.isEmpty) {
      ctrl.set(body: '☑️ ');
      return;
    }
    final i = lines.length - 1;
    final L = lines[i].trimLeft();
    String toggled;
    if (L.startsWith('☑️ ')) {
      toggled = L.replaceFirst('☑️ ', '🟪 ');
    } else if (L.startsWith('🟪 ')) {
      toggled = L.replaceFirst('🟪 ', '☑️ ');
    } else {
      toggled = '☑️ ${L.isEmpty ? '' : L}';
    }
    lines[i] = lines[i].replaceFirst(lines[i].trimLeft(), toggled);
    ctrl.set(body: lines.join('\n'));
  }

  void _pickColor(BuildContext c, EditorCtrl ctrl) {
    final colors = [
      0xFFFFF59D,
      0xFFC8E6C9,
      0xFFB3E5FC,
      0xFFD1C4E9,
      0xFFFFCCBC,
      0xFFFFFDE7,
    ];
    showModalBottomSheet<void>(
      context: c,
      builder: (_) => GridView.count(
        crossAxisCount: 6,
        padding: const EdgeInsets.all(12),
        children: colors
            .map(
              (v) => InkWell(
                onTap: () {
                  ctrl.set(color: v);
                  Navigator.pop(c);
                },
                child: Card(color: Color(v)),
              ),
            )
            .toList(),
      ),
    );
  }
}

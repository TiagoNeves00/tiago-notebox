import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/data/repos/revisions_repo.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/home/widgets/note_grid.dart';

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
        final n = await (db.select(db.notes)..where((t) => t.id.equals(widget.noteId!))).getSingle();
        ref.read(editorProvider.notifier).load(
          NoteDraft(title: n.title, body: n.body, color: n.color, folderId: n.folderId),
        );
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(editorProvider);
    final ctrl = ref.read(editorProvider.notifier);
    _title.value = _title.value.copyWith(text: st.title, selection: _title.selection);
    _body.value = _body.value.copyWith(text: st.body, selection: _body.selection);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Nova nota' : 'Editar nota'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: ctrl.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: ctrl.redo),
          IconButton(icon: const Icon(Icons.palette), onPressed: () => _pickColor(context, ctrl)),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final id = await ref.read(notesRepoProvider).upsert(
                id: widget.noteId, title: st.title, body: st.body, color: st.color, folderId: st.folderId,
              );
              await ref.read(revisionsRepoProvider).add(id, _snapshotJson(st));
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _FolderButton(st.folderId),
            const SizedBox(height: 8),
            TextField(
              controller: _title,
              decoration: const InputDecoration(hintText: 'Título', border: InputBorder.none),
              onChanged: (v) => ctrl.set(title: v),
            ),
            Expanded(
              child: TextField(
                controller: _body,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Escreve…', border: InputBorder.none),
                onChanged: (v) => ctrl.set(body: v),
              ),
            ),
            Row(children: [
              TextButton.icon(
                icon: const Icon(Icons.check_box_outlined),
                label: const Text('Checklist'),
                onPressed: () => _toggleChecklist(ctrl),
              ),
            ]),
          ],
        ),
      ),
      backgroundColor: st.color != null ? Color(st.color!) : null,
    );
  }

  String _snapshotJson(NoteDraft s) =>
      jsonEncode({'title': s.title, 'body': s.body, 'color': s.color, 'folderId': s.folderId});

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
    final colors = [0xFFFFF59D, 0xFFC8E6C9, 0xFFB3E5FC, 0xFFD1C4E9, 0xFFFFCCBC, 0xFFFFFDE7];
    showModalBottomSheet<void>(
      context: c,
      showDragHandle: true,
      builder: (_) => GridView.count(
        crossAxisCount: 6,
        padding: const EdgeInsets.all(12),
        children: colors
            .map((v) => InkWell(onTap: () { ctrl.set(color: v); Navigator.pop(c); },
                child: Card(color: Color(v))))
            .toList(),
      ),
    );
  }
}

class _FolderButton extends ConsumerWidget {
  final int? currentId;
  const _FolderButton(this.currentId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(foldersRepoProvider).watchAll();
    return StreamBuilder(
      stream: stream,
      builder: (_, snap) {
        final folders = snap.data ?? <Folder>[];
        final name = currentId == null
            ? 'Sem pasta'
            : (folders.firstWhere((f) => f.id == currentId, orElse: () => Folder(id: -1, name: 'Pasta', order: 0)).name);
        final color = folderColor(currentId);

        return Align(
          alignment: Alignment.centerRight,
            child: FilledButton.tonal(
            onPressed: () => _pickFolder(context, ref),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              minimumSize: Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.black26, width: 1.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(name, overflow: TextOverflow.ellipsis),
              const Icon(Icons.expand_more, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFolder(BuildContext ctx, WidgetRef ref) async {
    final repo = ref.read(foldersRepoProvider);
    final folders = await repo.watchAll().first;

    final chosen = await showModalBottomSheet<int?>(
      context: ctx,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(title: Text('Escolhe a pasta')),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                RadioListTile<int?>(
                  value: null,
                  groupValue: currentId,
                  title: const Text('Sem pasta'),
                  secondary: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: folderColor(null),
                      border: Border.all(color: Colors.black26, width: 1.5),
                    ),
                  ),
                  onChanged: (v) => Navigator.pop(sheetCtx, v),
                ),
                ...folders.map((f) => RadioListTile<int?>(
                      value: f.id,
                      groupValue: currentId,
                      title: Text(f.name),
                      secondary: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: folderColor(f.id),
                          border: Border.all(color: Colors.black26, width: 1.5),
                        ),
                      ),
                      onChanged: (v) => Navigator.pop(sheetCtx, v),
                    )),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Criar pasta'),
                  onTap: () async {
                    final name = await showModalBottomSheet<String>(
                      context: sheetCtx,
                      builder: (nameSheetCtx) {
                        final tc = TextEditingController();
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            TextField(controller: tc, decoration: const InputDecoration(labelText: 'Nome da pasta')),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => Navigator.pop(nameSheetCtx, tc.text.trim()),
                              child: const Text('Criar'),
                            ),
                          ]),
                        );
                      },
                    );
                    if (name != null && name.isNotEmpty) {
                      final db = ref.read(dbProvider);
                      final id = await db.into(db.folders).insert(FoldersCompanion.insert(name: name));
                      if (sheetCtx.mounted) Navigator.pop(sheetCtx, id);
                    }
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );

    ref.read(editorProvider.notifier).set(folderId: chosen);
  }
}
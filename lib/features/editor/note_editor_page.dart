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
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(editorProvider);
    final ctrl = ref.read(editorProvider.notifier);
    _title.value = _title.value.copyWith(text: st.title);
    _body.value = _body.value.copyWith(text: st.body);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Nova nota' : 'Editar nota'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: ctrl.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: ctrl.redo),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _pickColor(context, ctrl),
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
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            FilledButton.tonal(
              onPressed: () => _pickFolder(context),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  st.folderId == null
                      ? 'Seleciona pasta'
                      : 'Pasta #${st.folderId}',
                ),
              ),
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

  Future<void> _pickFolder(BuildContext context) async {
  final repo = ref.read(foldersRepoProvider);
  final folders = await repo.watchAll().first;
  final current = ref.read(editorProvider).folderId;

  final chosen = await showModalBottomSheet<int?>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const ListTile(title: Text('Escolhe a pasta')),
          RadioListTile<int?>(
            value: null, groupValue: current, title: const Text('Sem pasta'),
            onChanged: (v) => Navigator.pop(sheetCtx, v),
          ),
          ...folders.map((f) => RadioListTile<int?>(
                value: f.id, groupValue: current, title: Text(f.name),
                onChanged: (v) => Navigator.pop(sheetCtx, v),
              )),
          ListTile(
            leading: const Icon(Icons.add), title: const Text('Criar pasta'),
            onTap: () async {
              final id = await _createFolder(sheetCtx);
              if (id != null) Navigator.pop(sheetCtx, id);
            },
          ),
        ],
      ),
    ),
  );

  if (!mounted) return;
  ref.read(editorProvider.notifier).set(folderId: chosen);
}

Future<int?> _createFolder(BuildContext ctx) async {
  final tc = TextEditingController();
  final name = await showModalBottomSheet<String>(
    context: ctx,
    builder: (createCtx) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: tc, decoration: const InputDecoration(labelText: 'Nome da pasta')),
        const SizedBox(height: 12),
        FilledButton(onPressed: () => Navigator.pop(createCtx, tc.text.trim()), child: const Text('Criar')),
      ]),
    ),
  );
  if (name == null || name.isEmpty) return null;
  final db = ref.read(dbProvider);
  return db.into(db.folders).insert(FoldersCompanion.insert(name: name));
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
      toggled = '🟪 ${L.isEmpty ? '' : L}';
    }
    lines[i] = lines[i].replaceFirst(lines[i].trimLeft(), toggled);
    ctrl.set(body: lines.join('\n'));
  }

  void _pickColor(BuildContext ctx, EditorCtrl ctrl){
  final colors = [0xFFFFF59D,0xFFC8E6C9,0xFFB3E5FC,0xFFD1C4E9,0xFFFFCCBC,0xFFFFFDE7];
  showModalBottomSheet(
    context: ctx,
    builder: (sheetCtx) => GridView.count(
      crossAxisCount: 6, padding: const EdgeInsets.all(12),
      children: colors.map((v) => InkWell(
        onTap: () { ctrl.set(color: v); Navigator.pop(sheetCtx); },
        child: Card(color: Color(v)),
      )).toList(),
    ),
  );
}
}

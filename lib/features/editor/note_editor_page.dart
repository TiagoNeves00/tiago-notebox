import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/data/repos/revisions_repo.dart';
import 'package:notebox/features/editor/editor_baseline.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';


class NoteEditorPage extends ConsumerStatefulWidget {
  final int? noteId;
  const NoteEditorPage({super.key, this.noteId});
  @override ConsumerState<NoteEditorPage> createState() => _S();
}

class _S extends ConsumerState<NoteEditorPage> {
  final _title = TextEditingController(), _body = TextEditingController();

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final ctrl = ref.read(editorProvider.notifier);
    if (widget.noteId != null) {
      final db = ref.read(dbProvider);
      final n = await (db.select(db.notes)..where((t)=>t.id.equals(widget.noteId!))).getSingle();
      final d = NoteDraft(title: n.title, body: n.body, color: n.color, folderId: n.folderId);
      ctrl.load(d);
      ref.read(editorBaselineProvider.notifier).state = d; // agora fora do build
      setState((){}); // opcional
    } else {
      final d = NoteDraft();
      ctrl.load(d);
      ref.read(editorBaselineProvider.notifier).state = d;
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final st   = ref.watch(editorProvider);
    final base = ref.watch(editorBaselineProvider);
    final dirty = isDirty(st, base);

    _title.value = _title.value.copyWith(text: st.title, selection: _title.selection);
    _body.value  = _body.value.copyWith(text: st.body,  selection: _body.selection);

    Future<void> save() async {
      final id = await ref.read(notesRepoProvider).upsert(
        id: widget.noteId, title: st.title, body: st.body, color: st.color, folderId: st.folderId);
      await ref.read(revisionsRepoProvider).add(id, jsonEncode({
        'title': st.title, 'body': st.body, 'color': st.color, 'folderId': st.folderId,
      }));
      ref.read(editorBaselineProvider.notifier).state = st;
    }

    return WillPopScope(
      onWillPop: () async { if (dirty) await save(); return true; },
      child: Container(
        color: st.color != null ? Color(st.color!).withOpacity(.06) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: 'Título', border: InputBorder.none),
                onChanged: (v) => ref.read(editorProvider.notifier).set(title: v),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _body, maxLines: null,
                  decoration: const InputDecoration(hintText: 'Escreve…', border: InputBorder.none),
                  onChanged: (v) => ref.read(editorProvider.notifier).set(body: v),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.check_box_outlined),
                  label: const Text('Checklist'),
                  onPressed: () => _toggleChecklist(ref.read(editorProvider.notifier)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleChecklist(EditorCtrl ctrl) {
    final t = ref.read(editorProvider).body;
    final lines = t.split('\n');
    if (lines.isEmpty) { ctrl.set(body: '☑️ '); return; }
    final i = lines.length - 1, L = lines[i].trimLeft();
    final toggled = L.startsWith('☑️ ') ? L.replaceFirst('☑️ ','🟪 ')
                  : L.startsWith('🟪 ') ? L.replaceFirst('🟪 ','☑️ ')
                  : '☑️ ${L.isEmpty ? '' : L}';
    lines[i] = lines[i].replaceFirst(lines[i].trimLeft(), toggled);
    ctrl.set(body: lines.join('\n'));
  }
}

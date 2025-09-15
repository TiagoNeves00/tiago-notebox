import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

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
  @override
  ConsumerState<NoteEditorPage> createState() => _S();
}

class _S extends ConsumerState<NoteEditorPage> {
  final _title = TextEditingController(), _body = TextEditingController();
  ui.Image? _bgImg;
  String? _bgPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctrl = ref.read(editorProvider.notifier);
      if (widget.noteId != null) {
        final db = ref.read(dbProvider);
        final n = await (db.select(
          db.notes,
        )..where((t) => t.id.equals(widget.noteId!))).getSingle();
        final d = NoteDraft(
          title: n.title,
          body: n.body,
          color: n.color,
          folderId: n.folderId,
          bgKey: n.bgKey,
        );
        ctrl.load(d);
        ref.read(editorBaselineProvider.notifier).state = d;
      } else {
        final d = const NoteDraft();
        ctrl.load(d);
        ref.read(editorBaselineProvider.notifier).state = d;
      }
    });
  }

  Future<void> _loadBg(BuildContext ctx, String? path) async {
    if (path == null) {
      setState(() {
        _bgImg = null;
        _bgPath = null;
      });
      return;
    }
    if (_bgPath == path && _bgImg != null) return;
    final provider = AssetImage(path);
    final cfg = createLocalImageConfiguration(ctx);
    final c = Completer<ui.Image>();
    late final ImageStreamListener l;
    final s = provider.resolve(cfg);
    l = ImageStreamListener(
      (info, _) {
        s.removeListener(l);
        c.complete(info.image);
      },
      onError: (e, _) {
        s.removeListener(l);
        c.completeError(e);
      },
    );
    s.addListener(l);
    final img = await c.future;
    if (!mounted) return;
    setState(() {
      _bgImg = img;
      _bgPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(editorProvider);
    final base = ref.watch(editorBaselineProvider);
    final dirty = isDirty(st, base);

    if (_bgPath != st.bgKey) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _loadBg(context, st.bgKey),
      );
    }

    _title.value = _title.value.copyWith(
      text: st.title,
      selection: _title.selection,
    );
    _body.value = _body.value.copyWith(
      text: st.body,
      selection: _body.selection,
    );

    final String? bg = st.bgKey;
    final hasBg = bg != null;

    Future<void> save() async {
      final id = await ref
          .read(notesRepoProvider)
          .upsert(
            id: widget.noteId,
            title: st.title,
            body: st.body,
            color: st.color,
            folderId: st.folderId,
            bgKey: st.bgKey,
          );
      await ref
          .read(revisionsRepoProvider)
          .add(
            id,
            jsonEncode({
              'title': st.title,
              'body': st.body,
              'color': st.color,
              'folderId': st.folderId,
              'bgKey': st.bgKey,
            }),
          );
      ref.read(editorBaselineProvider.notifier).state = st;
    }

    final titleStyle = TextStyle(
      fontSize: 28, // Increased font size
      fontWeight: FontWeight.w900, // More bold
      color: hasBg ? Colors.white : null,
      shadows: hasBg
        ? const [Shadow(blurRadius: 2, color: Colors.black26)]
        : null,
    );
    final bodyStyle = TextStyle(
      fontSize: 21, // Slightly bigger body text
      fontWeight: FontWeight.w600, // More bold
      color: hasBg ? Colors.white : null,
      shadows: hasBg
        ? const [Shadow(blurRadius: 1, color: Colors.black26)]
        : null,
    );
    final hintStyle = TextStyle(color: hasBg ? Colors.white70 : null);

    final topPad = MediaQuery.paddingOf(context).top + kToolbarHeight - 30;

    return WillPopScope(
      onWillPop: () async {
        if (dirty) await save();
        return true;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (bg != null)
            Positioned.fill(
              child: Image.asset(
                bg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            ),
          if (bg != null)
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, topPad, 12, 12),
            child: Column(
              children: [
                TextField(
                  controller: _title,
                  style: titleStyle,
                  decoration: InputDecoration(
                    hintText: 'Título',
                    hintStyle: hintStyle,
                    border: InputBorder.none,
                  ),
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).set(title: v),
                ),
                const SizedBox(height: 8),
                Divider(height: 1, color: hasBg ? Colors.white24 : null),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _body,
                    maxLines: null,
                    style: bodyStyle,
                    decoration: InputDecoration(
                      hintText: 'Escreve…',
                      hintStyle: hintStyle,
                      border: InputBorder.none,
                    ),
                    onChanged: (v) =>
                        ref.read(editorProvider.notifier).set(body: v),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.check_box_outlined,
                      color: hasBg ? Colors.white : null,
                    ),
                    label: Text(
                      'Checklist',
                      style: TextStyle(color: hasBg ? Colors.white : null),
                    ),
                    onPressed: () =>
                        _toggleChecklist(ref.read(editorProvider.notifier)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleChecklist(EditorCtrl ctrl) {
    final t = ref.read(editorProvider).body;
    final lines = t.split('\n');
    if (lines.isEmpty) {
      ctrl.set(body: '☑️ ');
      return;
    }
    final i = lines.length - 1, L = lines[i].trimLeft();
    final toggled = L.startsWith('☑️ ')
        ? L.replaceFirst('☑️ ', '🟪 ')
        : L.startsWith('🟪 ')
        ? L.replaceFirst('🟪 ', '☑️ ')
        : '☑️ ${L.isEmpty ? '' : L}';
    lines[i] = lines[i].replaceFirst(lines[i].trimLeft(), toggled);
    ctrl.set(body: lines.join('\n'));
  }
}

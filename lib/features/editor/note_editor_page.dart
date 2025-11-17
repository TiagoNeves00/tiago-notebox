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
import 'package:notebox/features/home/widgets/editor_toolbar_host.dart';
import 'package:notebox/features/editor/widgets/line_editor.dart';
import 'package:notebox/theme/bg_text_palettes.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final int? noteId;
  const NoteEditorPage({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage>
    with TickerProviderStateMixin {
  final _title = TextEditingController();
  final _titleNode = FocusNode();
  final _lineCtrl = LineEditorController();

  ui.Image? _bgImg;
  String? _bgPath;

  late AnimationController _bgAnim;
  late AnimationController _contentAnim;

  Future<void> _loadBgImage(BuildContext ctx, String? path) async {
    final solid = parseSolid(path);

    // Fundo sólido → não há imagem a carregar
    if (path == null || solid != null) {
      _bgImg = null;
      _bgPath = path;
      _bgAnim.forward(from: 0);
      _contentAnim.forward(from: 0.0);
      setState(() {});
      return;
    }

    // mesmo bg → não recarregar
    if (_bgPath == path && _bgImg != null) {
      _bgAnim.forward(from: 0);
      _contentAnim.forward(from: 0.0);
      return;
    }

    _bgImg = null;
    _bgPath = path;
    setState(() {});

    // carregar imagem
    final cfg = createLocalImageConfiguration(ctx);
    final stream = AssetImage(path).resolve(cfg);

    final c = Completer<ui.Image>();
    late final ImageStreamListener l;

    l = ImageStreamListener(
      (info, _) {
        stream.removeListener(l);
        c.complete(info.image);
      },
      onError: (e, _) {
        stream.removeListener(l);
        c.completeError(e);
      },
    );

    stream.addListener(l);
    final img = await c.future;

    if (!mounted) return;

    setState(() => _bgImg = img);

    // Primeiro fade do fundo
    await _bgAnim.forward(from: 0);

    // Depois fade do conteúdo
    _contentAnim.forward(from: 0);
  }

  Future<void> _saveIfDirty() async {
    final st = ref.read(editorProvider);
    final base = ref.read(editorBaselineProvider);
    if (!isDirty(st, base)) return;

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

  @override
  void didUpdateWidget(NoteEditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteId != widget.noteId) {
      _bgImg = null;
      _bgPath = null;
    }
  }

  @override
  void initState() {
    super.initState();

    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _contentAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _title.addListener(() {
      ref.read(editorProvider.notifier).set(title: _title.text);
    });

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

        Future.microtask(() {
          ctrl.load(d);
        });

        ref.read(editorBaselineProvider.notifier).state = d;

        _title.text = d.title;
        _lineCtrl.setText(d.body);

        setState(() {});
        _loadBgImage(context, d.bgKey);
      } else {
        const d = NoteDraft();
        Future.microtask(() => ctrl.load(d));
        ref.read(editorBaselineProvider.notifier).state = d;
        _loadBgImage(context, null);
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _titleNode.dispose();
    _bgAnim.dispose();
    _contentAnim.dispose();
    super.dispose();
  }

  void _onChecklistPressed() => _lineCtrl.toggleChecklistForFocused();

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(editorProvider);

    final pal = paletteFor(st.bgKey, Theme.of(context).brightness);
    final solidColor = parseSolid(st.bgKey);

    final titleStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: pal.title,
      height: 1.2,
    );

    final bodyStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: pal.body,
      height: 1.38,
    );

    final topPad = MediaQuery.paddingOf(context).top + kToolbarHeight - 30;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: FadeTransition(
        opacity: _bgAnim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (solidColor != null)
              Positioned.fill(child: ColoredBox(color: solidColor))
            else if (_bgImg != null)
              RawImage(
                image: _bgImg,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),

            FadeTransition(
              opacity: _contentAnim,
              child: Padding(
                padding: EdgeInsets.fromLTRB(28, topPad, 22, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _title,
                      focusNode: _titleNode,
                      style: titleStyle,
                      decoration: const InputDecoration(
                        hintText: 'Título',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: LineEditor(
                        controller: _lineCtrl,
                        initialText: st.body,
                        style: bodyStyle,
                        onChanged: (txt) =>
                            ref.read(editorProvider.notifier).set(body: txt),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            FadeTransition(
              opacity: _contentAnim,
              child: Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: EditorToolbarHost(onChecklist: _onChecklistPressed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

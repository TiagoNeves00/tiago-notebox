import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:super_editor/super_editor.dart';

import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/data/repos/revisions_repo.dart';
import 'package:notebox/features/editor/editor_baseline.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/theme/bg_text_palettes.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final int? noteId;
  const NoteEditorPage({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorPage> createState() => _S();
}

class _S extends ConsumerState<NoteEditorPage> {
  // Título
  final _title = TextEditingController();
  final _titleNode = FocusNode();

  // SuperEditor
  late MutableDocument _document;
  late MutableDocumentComposer _composer;
  late Editor _editor;

  final _scrollCtrl = ScrollController();
  final _docLayoutKey = GlobalKey(); // para obter caret rect

  // BG
  ui.Image? _bgImg;
  String? _bgPath;

  // Proxy p/ listener (compat com versões antigas/novas)
  void Function(dynamic)? _docChangeProxy;

  // ===== Helpers plain <-> doc =====
  static final _uuid = const Uuid();

  static Iterable<DocumentNode> _iterNodes(MutableDocument doc) {
    final d = doc as dynamic;
    try {
      final count = d.getNodeCount();
      if (count is int) {
        return List<DocumentNode>.generate(
          count,
          (i) => d.getNodeAt(i) as DocumentNode,
        );
      }
    } catch (_) {}
    try {
      final nodes = d.nodes;
      if (nodes is Iterable) return nodes.cast<DocumentNode>();
    } catch (_) {}
    return const <DocumentNode>[];
  }

  static MutableDocument _docFromPlain(String body) {
    final lines = body.split('\n');
    final nodes = <DocumentNode>[];
    if (lines.isEmpty || (lines.length == 1 && lines.first.isEmpty)) {
      nodes.add(ParagraphNode(id: _uuid.v4(), text: AttributedText('')));
    } else {
      for (final l in lines) {
        nodes.add(ParagraphNode(id: _uuid.v4(), text: AttributedText(l)));
      }
    }
    return MutableDocument(nodes: nodes);
  }

  static String _plainFromDoc(MutableDocument doc) {
    final buffer = StringBuffer();
    for (final node in _iterNodes(doc)) {
      if (node is ParagraphNode) buffer.writeln(node.text.text);
    }
    final s = buffer.toString();
    return s.isNotEmpty ? s.substring(0, s.length - 1) : '';
  }

  Future<void> _loadBgImage(BuildContext ctx, String? path) async {
    if (path == null || parseSolid(path) != null) {
      setState(() { _bgImg = null; _bgPath = path; });
      return;
    }
    if (_bgPath == path && _bgImg != null) return;
    final provider = AssetImage(path);
    final cfg = createLocalImageConfiguration(ctx);
    final c = Completer<ui.Image>();
    late final ImageStreamListener l;
    final s = provider.resolve(cfg);
    l = ImageStreamListener((info, _) { s.removeListener(l); c.complete(info.image); },
        onError: (e, _) { s.removeListener(l); c.completeError(e); });
    s.addListener(l);
    final img = await c.future;
    if (!mounted) return;
    setState(() { _bgImg = img; _bgPath = path; });
  }

  Future<void> _saveIfDirty() async {
    final st = ref.read(editorProvider);
    final base = ref.read(editorBaselineProvider);
    if (!isDirty(st, base)) return;

    final id = await ref.read(notesRepoProvider).upsert(
      id: widget.noteId,
      title: st.title,
      body: st.body,
      color: st.color,
      folderId: st.folderId,
      bgKey: st.bgKey,
    );

    await ref.read(revisionsRepoProvider).add(
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

  // ===== Scroll do caret sempre visível =====
  void _scrollCaretIntoView() {
    final selection = _composer.selectionNotifier.value;
    if (selection == null || !selection.isCollapsed) return;

    final layoutState = _docLayoutKey.currentState;
    if (layoutState == null) return;

    try {
      final dynamic layout = layoutState; // DocumentLayoutState
      final Rect? rect = layout.getRectForSelection(selection) as Rect?;
      if (rect == null) return;

      // rect é em coordenadas locais do layout -> converter para global
      final renderObj = (layout as dynamic).context.findRenderObject();
      if (renderObj is! RenderBox) return;

      final topLeftGlobal = renderObj.localToGlobal(Offset(rect.left, rect.top));
      final bottomGlobal  = renderObj.localToGlobal(Offset(rect.left, rect.bottom)).dy;

      final mq = MediaQuery.of(context);
      final keyboard = mq.viewInsets.bottom;
      final screenH = mq.size.height;

      // limite visível acima do teclado + uma margem
      final visibleBottom = screenH - keyboard - 12.0;

      // se caret está por baixo da área visível, scroll para baixo
      if (bottomGlobal > visibleBottom) {
        final delta = bottomGlobal - visibleBottom;
        final target = (_scrollCtrl.offset + delta).clamp(
          0.0,
          _scrollCtrl.position.maxScrollExtent,
        );
        _scrollCtrl.animateTo(
          target,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      }

      // opcional: se caret muito colado ao topo, ajusta para baixo
      final visibleTop = mq.padding.top + 100.0;
      if (topLeftGlobal.dy < visibleTop) {
        final deltaUp = visibleTop - topLeftGlobal.dy;
        final target = (_scrollCtrl.offset - deltaUp).clamp(
          0.0,
          _scrollCtrl.position.maxScrollExtent,
        );
        _scrollCtrl.animateTo(
          target,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      // silencioso – preferimos não crashar por diferenças de versão
    }
  }

  void _attachDocListener() {
    _docChangeProxy ??= (dynamic _) => _schedulePropagateBody();
    final d = _document as dynamic;
    var attached = false;
    try { d.addListener(_docChangeProxy); attached = true; } catch (_) {}
    if (!attached) { try { d.addListener(_schedulePropagateBody); } catch (_) {} }
  }

  void _detachDocListener() {
    final d = _document as dynamic;
    try { d.removeListener(_docChangeProxy); } catch (_) {}
    try { d.removeListener(_schedulePropagateBody); } catch (_) {}
  }

  bool _propagateScheduled = false;
  void _schedulePropagateBody() {
    if (_propagateScheduled) return;
    _propagateScheduled = true;
    Future.microtask(() {
      if (!mounted) return;
      _propagateScheduled = false;
      ref.read(editorProvider.notifier).set(body: _plainFromDoc(_document));
      _scrollCaretIntoView(); // após qualquer alteração, garante visibilidade
    });
  }

  void _makeEditor() {
    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
    );
  }

  @override
  void initState() {
    super.initState();

    _document = _docFromPlain('');
    _composer = MutableDocumentComposer();
    _makeEditor();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctrl = ref.read(editorProvider.notifier);

      if (widget.noteId != null) {
        final db = ref.read(dbProvider);
        final n = await (db.select(db.notes)..where((t) => t.id.equals(widget.noteId!))).getSingle();
        final body = n.body ?? '';

        _detachDocListener();
        _document = _docFromPlain(body);
        _composer = MutableDocumentComposer();
        _makeEditor();
        _attachDocListener();

        final d = NoteDraft(
          title: n.title,
          body: body,
          color: n.color,
          folderId: n.folderId,
          bgKey: n.bgKey,
        );
        ctrl.load(d);
        ref.read(editorBaselineProvider.notifier).state = d;

        _title.text = d.title;
        setState(() {});
      } else {
        const d = NoteDraft();
        ctrl.load(d);
        ref.read(editorBaselineProvider.notifier).state = d;
        _attachDocListener();
      }

      // ouvir alterações de seleção -> manter caret visível
      _composer.selectionNotifier.addListener(_scrollCaretIntoView);
    });

    _title.addListener(() {
      Future.microtask(() {
        if (!mounted) return;
        ref.read(editorProvider.notifier).set(title: _title.text);
      });
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _titleNode.dispose();
    _composer.selectionNotifier.removeListener(_scrollCaretIntoView);
    _composer.removeListener(_schedulePropagateBody);
    _detachDocListener();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(editorProvider);
    final pal = paletteFor(st.bgKey, Theme.of(context).brightness);
    final solidColor = parseSolid(st.bgKey);

    if (_bgPath != st.bgKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadBgImage(context, st.bgKey));
    }

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
    final kb = MediaQuery.viewInsetsOf(context).bottom;

    // Reforço: sempre que o teclado muda, agendamos um scroll do caret
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollCaretIntoView());

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false, // controlamos com padding
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (solidColor != null)
            Positioned.fill(child: ColoredBox(color: solidColor))
          else if (st.bgKey != null)
            Positioned.fill(
              child: Image.asset(
                st.bgKey!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            ),
          if (st.bgKey != null)
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

          // Conteúdo com padding inferior = altura do teclado
          Padding(
            padding: EdgeInsets.fromLTRB(28, topPad, 22, kb + 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título sem bordas/fundo
                TextField(
                  controller: _title,
                  focusNode: _titleNode,
                  style: titleStyle,
                  decoration: const InputDecoration(
                    hintText: 'Titulo',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: pal.divider),
                const SizedBox(height: 8),

                // Corpo com SuperEditor – com scrollController + documentLayoutKey
                Expanded(
                  child: SuperEditor(
                    editor: _editor,
                    document: _document,
                    composer: _composer,
                    scrollController: _scrollCtrl,
                    documentLayoutKey: _docLayoutKey,
                    stylesheet: defaultStylesheet.copyWith(
                      addRulesAfter: [
                        StyleRule(
                          BlockSelector.all,
                          (doc, node) => {
                            Styles.padding: const CascadingPadding.only(left: 6, bottom: 10),
                          },
                        ),
                        StyleRule(
                          const BlockSelector('paragraph'),
                          (doc, node) => {
                            Styles.textStyle: bodyStyle,
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

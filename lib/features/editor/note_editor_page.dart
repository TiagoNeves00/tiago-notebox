// note_editor_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/data/repos/revisions_repo.dart';
import 'package:notebox/features/editor/editor_baseline.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/editor/editor_save_handler.dart';
import 'package:notebox/features/home/widgets/rich_note_editor.dart';
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

  DateTime? _lastEdited;

  ProviderContainer? _container;

  QuillController? _quillCtrl;
  StreamSubscription? _docSub;

  final _bodyFocus = FocusNode();
  final _bodyScroll = ScrollController();

  ui.Image? _bgImg;
  String? _bgPath;

  late final AnimationController _bgAnim;
  late final AnimationController _contentAnim;

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final sameDay = now.year == d.year && now.month == d.month && now.day == d.day;

    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');

    if (sameDay) return 'Hoje · $hh:$mm';

    final dd = d.day.toString().padLeft(2, '0');
    final mo = d.month.toString().padLeft(2, '0');
    return '$dd/$mo/${d.year} · $hh:$mm';
  }

  // raw antigo (texto) OU delta json (List)
  Document _parseBodyToDoc(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return Document.fromJson(decoded);
    } catch (_) {
      // ignore
    }

    // fallback: texto simples (garante newline final)
    final d = Document();
    final txt = raw.trim().isEmpty ? '' : raw;
    final normalized = txt.isEmpty ? '' : (txt.endsWith('\n') ? txt : '$txt\n');
    if (normalized.isNotEmpty) d.insert(0, normalized);
    return d;
  }

  String _docToDeltaJson(QuillController c) {
    final delta = c.document.toDelta();
    return jsonEncode(delta.toJson());
  }

  void _attachDocListener(QuillController c) {
    _docSub?.cancel();
    _docSub = c.document.changes.listen((_) {
      if (!mounted) return;
      ref.read(editorProvider.notifier).set(body: _docToDeltaJson(c));
    });
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  _container ??= ProviderScope.containerOf(context, listen: false);
}

  void _setQuillDocument(Document doc) {
    final old = _quillCtrl;
    if (old != null) {
      _docSub?.cancel();
      _docSub = null;
      old.dispose();
    }

    final c = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    c.formatSelection(Attribute.clone(
      Attribute.size,
      '30', // tamanho do corpo
    ));

    c.formatSelection(Attribute.clone(
      Attribute.lineHeight,
      '1.5', // espaçamento entre linhas
    ));

    _quillCtrl = c;
    _attachDocListener(c);

    // empurra estado inicial (evita edge-cases no dirty)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(editorProvider.notifier).set(body: _docToDeltaJson(c));
    });
  }

  Future<void> saveNow() async {
    if (!mounted) return;

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

    if (!mounted) return;

    ref.read(editorBaselineProvider.notifier).state = st;
    setState(() => _lastEdited = DateTime.now());
  }

  Future<void> _loadBgImage(BuildContext ctx, String? path) async {
    final solid = parseSolid(path);

    if (path == null || solid != null) {
      _bgImg = null;
      _bgPath = path;
      _bgAnim.forward(from: 0);
      _contentAnim.forward(from: 0);
      if (mounted) setState(() {});
      return;
    }

    if (_bgPath == path && _bgImg != null) {
      _bgAnim.forward(from: 0);
      _contentAnim.forward(from: 0);
      return;
    }

    _bgImg = null;
    _bgPath = path;
    if (mounted) setState(() {});

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
    await _bgAnim.forward(from: 0);
    _contentAnim.forward(from: 0);
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

    _setQuillDocument(Document());

    _title.addListener(() {
      if (!mounted) return;
      ref.read(editorProvider.notifier).set(title: _title.text);
    });

    // IMPORTANT: registar handler fora do build/initState (evita erro Riverpod)
    Future.microtask(() {
      if (!mounted) return;
      ref.read(editorSaveHandlerProvider.notifier).state = saveNow;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final ctrl = ref.read(editorProvider.notifier);

      if (widget.noteId != null) {
        final db = ref.read(dbProvider);
        final n = await (db.select(db.notes)
              ..where((t) => t.id.equals(widget.noteId!)))
            .getSingle();

        if (!mounted) return;

        _lastEdited = n.updatedAt;

        final d = NoteDraft(
          title: n.title,
          body: n.body,
          color: n.color,
          folderId: n.folderId,
          bgKey: n.bgKey,
        );

        Future.microtask(() => ctrl.load(d));
        ref.read(editorBaselineProvider.notifier).state = d;

        _title.text = d.title;
        _setQuillDocument(_parseBodyToDoc(d.body));

        setState(() {});
        _loadBgImage(context, d.bgKey);
      } else {
        const d = NoteDraft();
        Future.microtask(() => ctrl.load(d));
        ref.read(editorBaselineProvider.notifier).state = d;

        _lastEdited = null;
        _title.text = '';
        _setQuillDocument(Document());

        setState(() {});
        _loadBgImage(context, null);
      }
    });
  }

  @override
  void dispose() {

    _title.dispose();
    _titleNode.dispose();

    _bodyFocus.dispose();
    _bodyScroll.dispose();

    _docSub?.cancel();
    _docSub = null;

    final c = _quillCtrl;
    if (c != null) c.dispose();

    _bgAnim.dispose();
    _contentAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(editorProvider);

    final bgKey = st.bgKey;

// se bgKey mudou, recarrega fundo (imagem ou cor)
if (_bgPath != bgKey) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    _loadBgImage(context, bgKey);
  });
}

    final pal = paletteFor(st.bgKey, Theme.of(context).brightness);
    final solidColor = parseSolid(st.bgKey);

    final titleStyle = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w900,
      color: pal.title,
      height: 1.2,
    );

    final bodyStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: pal.body,
      height: 1.55,
    );

    final topPad = MediaQuery.paddingOf(context).top + kToolbarHeight - 30;
    final qc = _quillCtrl;

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
              )
            else
              const Positioned.fill(child: ColoredBox(color: Color(0xFF08131D))),

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
                        filled: false,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (_lastEdited != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Última edição · ${_formatDate(_lastEdited!)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: pal.body.withOpacity(0.55),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Divider(
                      height: 16,
                      thickness: 0.6,
                      color: Colors.white.withOpacity(0.35),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: qc == null
                          ? const SizedBox.shrink()
                          : RichNoteEditor(
                              controller: qc,
                              focusNode: _bodyFocus,
                              scrollController: _bodyScroll,
                              textStyle: bodyStyle,
                              cursorColor: const Color(0xFFEA00FF),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
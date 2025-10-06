// lib/features/editor/note_editor_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/data/repos/revisions_repo.dart';
import 'package:notebox/features/editor/editor_baseline.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/home/widgets/recorder_overlay.dart';
import 'package:notebox/theme/bg_text_palettes.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final int? noteId;
  const NoteEditorPage({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorPage> createState() => _S();
}

class _S extends ConsumerState<NoteEditorPage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _titleNode = FocusNode();
  final _bodyNode = FocusNode();

  ui.Image? _bgImg;
  String? _bgPath;

  // Estado do “modo heading” para próximas linhas
  int? _activeHeading; // 1/2/3 ou null

  @override
  void initState() {
    super.initState();
    // carrega nota no editor
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctrl = ref.read(editorProvider.notifier);
      if (widget.noteId != null) {
        final db = ref.read(dbProvider);
        final n = await (db.select(db.notes)
              ..where((t) => t.id.equals(widget.noteId!)))
            .getSingle();
        final d = NoteDraft(
          title: n.title,
          body: n.body,
          color: n.color,
          folderId: n.folderId,
          bgKey: n.bgKey,
        );
        ctrl.load(d);
        ref.read(editorBaselineProvider.notifier).state = d;
        _title.text = d.title;
        _body.text = d.body;
      } else {
        const d = NoteDraft();
        ctrl.load(d);
        ref.read(editorBaselineProvider.notifier).state = d;
      }
    });

    // Duplica checklist na próxima linha quando carrega Enter
    _bodyNode.addListener(() {
      // sem comportamento aqui; tratamos no onChanged / onEditingComplete se necessário
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _titleNode.dispose();
    _bodyNode.dispose();
    super.dispose();
  }

  Future<void> _loadBgImage(BuildContext ctx, String? path) async {
    if (path == null || parseSolid(path) != null) {
      setState(() {
        _bgImg = null;
        _bgPath = path;
      });
      return;
    }
    if (_bgPath == path && _bgImg != null) return;
    final provider = AssetImage(path);
    final cfg = createLocalImageConfiguration(ctx);
    final c = Completer<ui.Image>();
    late final ImageStreamListener l;
    final s = provider.resolve(cfg);
    l = ImageStreamListener((info, _) {
      s.removeListener(l);
      c.complete(info.image);
    }, onError: (e, _) {
      s.removeListener(l);
      c.completeError(e);
    });
    s.addListener(l);
    final img = await c.future;
    if (!mounted) return;
    setState(() {
      _bgImg = img;
      _bgPath = path;
    });
  }

  // Helpers -------------------------------------------------------------------

  void _insertAtCursor(TextEditingController c, String text) {
    final sel = c.selection;
    final t = c.text;
    final start = sel.isValid ? sel.start : t.length;
    final end = sel.isValid ? sel.end : t.length;
    final newText = t.replaceRange(start, end, text);
    c.value = c.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length),
      composing: TextRange.empty,
    );
  }

  // Linha atual (índices de início/fim)
  (int start, int end) _currentLineBounds(TextEditingController c) {
    final txt = c.text;
    final idx = c.selection.isValid ? c.selection.start : txt.length;
    int s = txt.lastIndexOf('\n', idx - 1);
    int e = txt.indexOf('\n', idx);
    if (s == -1) s = 0; else s = s + 1;
    if (e == -1) e = txt.length;
    return (s, e);
  }

  void _toggleChecklistAtCursor() {
    final (s, e) = _currentLineBounds(_body);
    final line = _body.text.substring(s, e);
    // se começa com “☐ ” troca para “☑ ”; senão se começa com “☑ ” volta para “☐ ”; senão insere “☐ ”
    String newLine;
    if (line.startsWith('☐ ')) {
      newLine = '☑ ${line.substring(2)}';
    } else if (line.startsWith('☑ ')) {
      newLine = '☐ ${line.substring(2)}';
    } else {
      newLine = '☐ $line';
    }
    final newText = _body.text.replaceRange(s, e, newLine);
    final caret = s + 2; // deixa cursor depois do símbolo
    _body.value = _body.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  void _duplicateChecklistOnEnter(String value) {
    // quando o user insere \n, se a linha anterior tinha checklist, cria outra “☐ ”
    // Detecta último char inserido
    final sel = _body.selection;
    if (!sel.isValid || sel.start == 0) return;
    final idx = sel.start;
    if (idx > 0 && _body.text[idx - 1] == '\n') {
      // linha anterior:
      final before = _body.text.substring(0, idx - 1);
      final lastNl = before.lastIndexOf('\n');
      final lineStart = lastNl == -1 ? 0 : lastNl + 1;
      final prevLine = before.substring(lineStart);
      if (prevLine.startsWith('☐ ') || prevLine.startsWith('☑ ')) {
        _insertAtCursor(_body, '☐ ');
      } else if (_activeHeading != null) {
        // aplica heading ativo como prefixo sem marca
        // (apenas semântica visual no editor; persistimos puro)
      }
    }
  }

  Future<void> _pickImageAndInsert() async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img == null) return;
      // insere marcador persistente
      _insertAtCursor(_body, '[img:${img.path}]');
      // Se quiseres inserir nova linha após a imagem:
      _insertAtCursor(_body, '\n');
      ref.read(editorProvider.notifier).set(body: _body.text);
    } catch (_) {}
  }

  Future<void> _startVoiceRecorder() async {
    // Fecha teclado e abre overlay de gravação
    FocusManager.instance.primaryFocus?.unfocus();
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => RecorderOverlay(
        onFinish: (path, _ms) {
          // insere marcador áudio e nova linha
          _insertAtCursor(_body, '[audio:$path]\n');
          ref.read(editorProvider.notifier).set(body: _body.text);
        },
      ),
    );
  }

  void _applyHeading(int level) {
    // Aplica estilo “semântico” ao editor:
    // Persistência continua em texto simples; mostramos maior no editor
    setState(() {
      _activeHeading = (_activeHeading == level) ? null : level;
    });
    // Aumenta tamanho da linha atual visualmente (sem decorar markdown)
    final (s, e) = _currentLineBounds(_body);
    // Não mexemos no texto; o estilo é aplicado no build via _activeHeading + caret pos
    // Contudo, se a linha está vazia, inserimos um espaço para o estilo “pegar”
    if (s == e) {
      _insertAtCursor(_body, '');
    }
  }

  TextStyle _bodyStyleForLine(TextStyle base) {
    // aplica fonte maior conforme heading ativo se o cursor estiver nessa linha
    if (_activeHeading == null) return base;
    final (s, e) = _currentLineBounds(_body);
    final caret = _body.selection.isValid ? _body.selection.start : -1;
    if (caret < s || caret > e) return base;
    switch (_activeHeading) {
      case 1:
        return base.copyWith(fontSize: 28, fontWeight: FontWeight.w800);
      case 2:
        return base.copyWith(fontSize: 24, fontWeight: FontWeight.w700);
      case 3:
        return base.copyWith(fontSize: 21, fontWeight: FontWeight.w700);
      default:
        return base;
    }
  }

  Future<void> _saveIfDirty() async {
    final st = ref.read(editorProvider);
    final base = ref.read(editorBaselineProvider);
    final dirty = isDirty(st, base);
    if (!dirty) return;
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

  // Build ---------------------------------------------------------------------

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
    );
    final baseBodyStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: pal.body,
      height: 1.35,
    );
    final hintStyle = TextStyle(color: pal.hint);
    final bodyStyle = _bodyStyleForLine(baseBodyStyle);

    final topPad = MediaQuery.paddingOf(context).top + kToolbarHeight - 30;
    final kb = MediaQuery.of(context).viewInsets.bottom;
    final showBar = kb > 0;

    // Sync draft com controllers
    ref.listen<NoteDraft>(editorProvider, (_, d) {
      if (_title.text != d.title) {
        _title.value = _title.value.copyWith(text: d.title, selection: _title.selection);
      }
      if (_body.text != d.body) {
        _body.value = _body.value.copyWith(text: d.body, selection: _body.selection);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        await _saveIfDirty();
        return true;
      },
      child: Stack(
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
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0x33000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, topPad, 22, showBar ? (kb + 72) : 22),
            child: Column(
              children: [
                TextField(
                  controller: _title,
                  focusNode: _titleNode,
                  style: titleStyle,
                  decoration: InputDecoration(
                    hintText: 'Título',
                    hintStyle: hintStyle,
                    border: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => ref.read(editorProvider.notifier).set(title: v),
                ),
                const SizedBox(height: 12),
                Divider(height: 5, color: pal.divider),
                const SizedBox(height: 24),
                Expanded(
                  child: TextField(
                    controller: _body,
                    focusNode: _bodyNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onChanged: (v) {
                      ref.read(editorProvider.notifier).set(body: v);
                      _duplicateChecklistOnEnter(v);
                    },
                    style: bodyStyle,
                    decoration: InputDecoration(
                      hintText: 'Escreve…',
                      hintStyle: hintStyle,
                      border: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra sobre o teclado
          if (showBar)
            Positioned(
              left: 0, right: 0, bottom: kb,
              child: const _BottomShadow(),
            ),
          if (showBar)
            Positioned(
              left: 12,
              right: 12,
              bottom: kb + 12,
              child: _ComposeBar(
                onPickImage: _pickImageAndInsert,
                onToggleChecklist: _toggleChecklistAtCursor,
                onRecordVoice: _startVoiceRecorder,
                onHeading: _applyHeading,
                activeHeading: _activeHeading,
              ),
            ),
        ],
      ),
    );
  }
}

// Barra de composição ----------------------------------------------------------

class _ComposeBar extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onToggleChecklist;
  final VoidCallback onRecordVoice;
  final void Function(int level) onHeading;
  final int? activeHeading;

  const _ComposeBar({
    required this.onPickImage,
    required this.onToggleChecklist,
    required this.onRecordVoice,
    required this.onHeading,
    required this.activeHeading,
  });

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFFEA00FF);
    final cs = Theme.of(context).colorScheme;

    Widget neonIcon(IconData icon, VoidCallback onTap, {bool active = false}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0E1720),
            border: Border.all(color: active ? neon : cs.outlineVariant, width: 1.2),
            boxShadow: active
                ? [BoxShadow(color: neon.withOpacity(.35), blurRadius: 12)]
                : const [],
          ),
          child: Icon(icon, color: Colors.white),
        ),
      );
    }

    Widget headingBtn(String t, int level) {
      final active = activeHeading == level;
      return GestureDetector(
        onTap: () => onHeading(level),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0E1720),
            border: Border.all(color: active ? neon : cs.outlineVariant, width: 1.2),
            boxShadow: active
                ? [BoxShadow(color: neon.withOpacity(.35), blurRadius: 12)]
                : const [],
          ),
          child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1119).withOpacity(.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00F5FF).withOpacity(.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            neonIcon(Icons.image_outlined, onPickImage),
            neonIcon(Icons.check_box, onToggleChecklist),
            neonIcon(Icons.mic, onRecordVoice),
            Row(
              children: [
                headingBtn('H1', 1),
                const SizedBox(width: 8),
                headingBtn('H2', 2),
                const SizedBox(width: 8),
                headingBtn('H3', 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomShadow extends StatelessWidget {
  const _BottomShadow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 32,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [Color(0xE6000000), Color(0x00000000)],
          ),
        ),
      ),
    );
  }
}

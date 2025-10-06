import 'package:flutter/material.dart';
import 'package:notebox/features/editor/note_blocks.dart';

typedef InsertImage = Future<String?> Function(); // devolve path da imagem
typedef StartRecord = Future<Map<String, dynamic>?> Function(); // {path, durationMs}
typedef OnBlocksChanged = void Function(List<NoteBlock> blocks);

class KeyboardToolbar extends StatefulWidget {
  final List<NoteBlock> blocks;
  final int insertIndex; // onde inserir novos blocos
  final OnBlocksChanged onChanged;
  final InsertImage onPickImage;
  final StartRecord onRecordAudio;

  const KeyboardToolbar({
    super.key,
    required this.blocks,
    required this.insertIndex,
    required this.onChanged,
    required this.onPickImage,
    required this.onRecordAudio,
  });

  @override
  State<KeyboardToolbar> createState() => _KeyboardToolbarState();
}

class _KeyboardToolbarState extends State<KeyboardToolbar> {
  bool textMenu = false; // false=principal; true=H1/H2/H3

  void _applyHeading(int h) {
    // procura bloco de texto na posição (ou cria)
    if (widget.blocks.isEmpty || widget.insertIndex >= widget.blocks.length) {
      widget.blocks.add(TextBlock('', heading: h));
    } else {
      final b = widget.blocks[widget.insertIndex];
      if (b is TextBlock) {
        b.heading = h;
      } else {
        widget.blocks.insert(widget.insertIndex, TextBlock('', heading: h));
      }
    }
    widget.onChanged(List.of(widget.blocks));
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFFEA00FF);
    final kb = MediaQuery.of(context).viewInsets.bottom;
    if (kb == 0) return const SizedBox.shrink();

    Widget btn(IconData i, VoidCallback onTap, {String? t}) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: neon.withOpacity(.35), blurRadius: 12)],
      ),
      child: IconButton(
        tooltip: t,
        icon: Icon(i, color: Colors.white, size: 26),
        onPressed: onTap,
      ),
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: kb),
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1720).withOpacity(.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: neon.withOpacity(.55)),
          boxShadow: [BoxShadow(color: neon.withOpacity(.20), blurRadius: 24)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: textMenu
              ? [
                  btn(Icons.title, () { _applyHeading(1); }, t: 'H1'),
                  btn(Icons.title, () { _applyHeading(2); }, t: 'H2'),
                  btn(Icons.title, () { _applyHeading(3); }, t: 'H3'),
                  btn(Icons.close, () { setState(() => textMenu = false); }, t: 'Fechar'),
                ]
              : [
                  // 1) Imagem
                  btn(Icons.photo_library_outlined, () async {
                    final p = await widget.onPickImage();
                    if (p == null) return;
                    widget.blocks.insert(widget.insertIndex, ImageBlock(p));
                    widget.onChanged(List.of(widget.blocks));
                  }, t: 'Inserir imagem'),

                  // 2) Checklist (igual ao botão isolado que já tinhas)
                  btn(Icons.check_box_outlined, () {
                    widget.blocks.insert(widget.insertIndex, TextBlock('□ ', checklist: true));
                    widget.onChanged(List.of(widget.blocks));
                  }, t: 'Checklist'),

                  // 3) Gravar áudio (fecha teclado + abre sheet no teu handler)
                  btn(Icons.mic_none, () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    final r = await widget.onRecordAudio(); // {path, durationMs}
                    if (r == null) return;
                    widget.blocks.insert(widget.insertIndex,
                      AudioBlock(path: r['path'] as String, durationMs: r['durationMs'] as int));
                    widget.onChanged(List.of(widget.blocks));
                  }, t: 'Gravar áudio'),

                  // 4) Texto (abre submenu H1/H2/H3)
                  btn(Icons.text_fields, () { setState(() => textMenu = true); }, t: 'Tamanho do texto'),
                ],
        ),
      ),
    );
  }
}

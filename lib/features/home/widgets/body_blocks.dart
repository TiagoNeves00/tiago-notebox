import 'dart:io';
import 'package:flutter/material.dart';

/// Token de imagem no corpo: [[img:/path|L]]  (L=grande, S=pequena)
const _imgTokenPrefix = '[[img:';
const _imgTokenSuffix = ']]';

enum _BlockType { text, image }

class _Block {
  final _BlockType type;
  String text; // quando type=text
  String path; // quando type=image
  bool isLarge;
  _Block.text(this.text)
      : type = _BlockType.text,
        path = '',
        isLarge = true;
  _Block.image(this.path, this.isLarge)
      : type = _BlockType.image,
        text = '';
}

List<_Block> _parseBody(String body) {
  final out = <_Block>[];
  var i = 0;
  while (i < body.length) {
    final start = body.indexOf(_imgTokenPrefix, i);
    if (start == -1) {
      out.add(_Block.text(body.substring(i)));
      break;
    }
    if (start > i) out.add(_Block.text(body.substring(i, start)));
    final end = body.indexOf(_imgTokenSuffix, start);
    if (end == -1) {
      out.add(_Block.text(body.substring(start)));
      break;
    }
    final token =
        body.substring(start + _imgTokenPrefix.length, end); // path|L
    final sep = token.lastIndexOf('|');
    String path = token;
    bool isLarge = true;
    if (sep != -1) {
      path = token.substring(0, sep);
      final sz = token.substring(sep + 1);
      isLarge = (sz.toUpperCase() != 'S');
    }
    out.add(_Block.image(path, isLarge));
    i = end + _imgTokenSuffix.length;
  }
  return out;
}

String _composeBody(List<_Block> blocks) {
  final b = StringBuffer();
  for (final bl in blocks) {
    if (bl.type == _BlockType.text) {
      b.write(bl.text);
    } else {
      final sz = bl.isLarge ? 'L' : 'S';
      b.write('$_imgTokenPrefix${bl.path}|$sz$_imgTokenSuffix');
    }
  }
  return b.toString();
}

class EditableBodyBlocks extends StatefulWidget {
  const EditableBodyBlocks({
    super.key,
    required this.initialBody,
    required this.textStyle,
    required this.hintStyle,
    required this.neonColor,
    required this.onChanged,
    this.scrollController,
  });

  final String initialBody;
  final TextStyle textStyle;
  final TextStyle hintStyle; // mantido por compat.
  final Color neonColor;
  final void Function(String) onChanged;
  final ScrollController? scrollController;

  @override
  EditableBodyBlocksState createState() => EditableBodyBlocksState();
}

class EditableBodyBlocksState extends State<EditableBodyBlocks> {
  final _textCtrls = <TextEditingController>[];
  final _focusNodes = <FocusNode>[];
  final _rowKeys = <GlobalKey>[];
  late List<_Block> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = _parseBody(widget.initialBody);
    _rebuildControllers();
  }

  @override
  void didUpdateWidget(covariant EditableBodyBlocks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBody != widget.initialBody &&
        widget.initialBody != _composeNow()) {
      _blocks = _parseBody(widget.initialBody);
      _rebuildControllers();
    }
  }

  @override
  void dispose() {
    for (final c in _textCtrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ---------- controllers/focus ----------
  void _rebuildControllers() {
    for (final c in _textCtrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _textCtrls.clear();
    _focusNodes.clear();
    _rowKeys.clear();

    for (final b in _blocks) {
      _rowKeys.add(GlobalKey());
      if (b.type == _BlockType.text) {
        final c = TextEditingController(text: b.text);
        c.addListener(_onAnyChanged);
        _textCtrls.add(c);

        final f = FocusNode();
        // Quando o foco muda → garantir visibilidade
        f.addListener(() {
          if (f.hasFocus) _scheduleEnsureVisible();
        });
        _focusNodes.add(f);
      } else {
        _textCtrls.add(TextEditingController(text: ''));
        _focusNodes.add(FocusNode());
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureCaretVisible());
  }

  void _onAnyChanged() {
    // refletir texto dos controllers nos blocks
    var ti = 0;
    for (var i = 0; i < _blocks.length; i++) {
      if (_blocks[i].type == _BlockType.text) {
        _blocks[i].text = _textCtrls[ti].text;
        ti++;
      }
    }
    widget.onChanged(_composeNow());
    _scheduleEnsureVisible();
  }

  String _composeNow() => _composeBody(_blocks);

  // ---------- API pública usada pela página ----------
  void insertImageAtCaret(String path) {
    int focusedTextIdx = -1;
    for (var i = 0; i < _focusNodes.length; i++) {
      if (_focusNodes[i].hasFocus) {
        focusedTextIdx = i;
        break;
      }
    }
    if (focusedTextIdx == -1) {
      setState(() {
        _blocks.add(_Block.image(path, true));
        _blocks.add(_Block.text(''));
        _rebuildControllers();
      });
      widget.onChanged(_composeNow());
      _scheduleEnsureVisible();
      return;
    }

    final textBlockIdx = _blockIndexForTextIndex(focusedTextIdx);
    final ctrl = _textCtrls[focusedTextIdx];
    final sel = ctrl.selection;
    final before =
        sel.start <= 0 ? '' : ctrl.text.substring(0, sel.start);
    final after =
        sel.end >= ctrl.text.length ? '' : ctrl.text.substring(sel.end);

    setState(() {
      _blocks.removeAt(textBlockIdx);
      final insertAt = textBlockIdx;
      _blocks.insertAll(insertAt, <_Block>[
        _Block.text(before),
        _Block.image(path, true),
        _Block.text(after),
      ]);
      _rebuildControllers();

      final afterTextCtrlIdx = _textIndexForBlock(insertAt + 2);
      if (afterTextCtrlIdx != -1) {
        _focusNodes[afterTextCtrlIdx].requestFocus();
        final c = _textCtrls[afterTextCtrlIdx];
        c.selection = TextSelection.collapsed(offset: c.text.length);
      }
    });

    widget.onChanged(_composeNow());
    _scheduleEnsureVisible();
  }

  // ---------- mapeamentos ----------
  int _blockIndexForTextIndex(int textIndex) {
    var ti = -1;
    for (var i = 0; i < _blocks.length; i++) {
      if (_blocks[i].type == _BlockType.text) {
        ti++;
        if (ti == textIndex) return i;
      }
    }
    return -1;
  }

  int _textIndexForBlock(int blockIndex) {
    var ti = -1;
    for (var i = 0; i <= blockIndex && i < _blocks.length; i++) {
      if (_blocks[i].type == _BlockType.text) ti++;
    }
    return ti;
  }

  // ---------- scroll/caret visibility ----------
  void _scheduleEnsureVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureCaretVisible());
  }

  void _ensureCaretVisible() {
    for (var i = 0; i < _focusNodes.length; i++) {
      if (_focusNodes[i].hasFocus) {
        final bi = _blockIndexForTextIndex(i);
        if (bi >= 0 && bi < _rowKeys.length) {
          final ctx = _rowKeys[bi].currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              alignment: 0.98,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
            );
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final neon = widget.neonColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0, t = 0; i < _blocks.length; i++)
          _blocks[i].type == _BlockType.text
              ? _TextRow(
                  key: _rowKeys[i],
                  controller: _textCtrls[t],
                  focusNode: _focusNodes[t++],
                  style: widget.textStyle,
                  onSelectionChange: _scheduleEnsureVisible,
                )
              : _ImageRow(
                  key: _rowKeys[i],
                  path: _blocks[i].path,
                  isLarge: _blocks[i].isLarge,
                  neon: neon,
                  onToggleSize: () {
                    setState(() {
                      _blocks[i].isLarge = !_blocks[i].isLarge;
                    });
                    widget.onChanged(_composeNow());
                    _scheduleEnsureVisible();
                  },
                  onDelete: () {
                    setState(() {
                      _blocks.removeAt(i);
                      if (!_blocks.any((b) => b.type == _BlockType.text)) {
                        _blocks.add(_Block.text(''));
                      }
                      _rebuildControllers();
                    });
                    widget.onChanged(_composeNow());
                    _scheduleEnsureVisible();
                  },
                ),
      ],
    );
  }
}

class _TextRow extends StatelessWidget {
  const _TextRow({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.onSelectionChange,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final VoidCallback onSelectionChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, right: 6),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: style,
        onTap: onSelectionChange,
        onEditingComplete: onSelectionChange,
        onSubmitted: (_) => onSelectionChange(),
        onChanged: (_) => onSelectionChange(),
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _ImageRow extends StatelessWidget {
  const _ImageRow({
    super.key,
    required this.path,
    required this.isLarge,
    required this.neon,
    required this.onToggleSize,
    required this.onDelete,
  });

  final String path;
  final bool isLarge;
  final Color neon;
  final VoidCallback onToggleSize;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final width = MediaQuery.of(context).size.width;
    final maxW = isLarge ? width - 56 : width * 0.66;
    final height = isLarge ? 220.0 : 140.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Stack(
        children: [
          Container(
            width: maxW,
            height: height,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: neon.withOpacity(.9), width: 1.2),
              boxShadow: [
                BoxShadow(color: neon.withOpacity(.35), blurRadius: 12),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Image.file(File(path), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                _CircleIcon(
                  icon: isLarge
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  onTap: onToggleSize,
                ),
                const SizedBox(width: 8),
                _CircleIcon(
                  icon: Icons.delete_forever_rounded,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

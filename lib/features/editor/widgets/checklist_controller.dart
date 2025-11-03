import 'package:flutter/material.dart';

const _kTok0 = '[[chk:0]] ';
const _kTok1 = '[[chk:1]] ';
final  _reTok = RegExp(r'^\[\[chk:(0|1)\]\]\s');

class ChecklistController extends TextEditingController {
  ChecklistController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, bool? withComposing}) {
    final lines = text.split('\n');
    final out = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final m = _reTok.firstMatch(line);
      final checked = m != null && m.group(1) == '1';
      final content = m != null ? line.substring(m.end) : line;

      if (m != null) {
        out.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () => toggleAtLine(i),
            child: _box(context, checked),
          ),
        ));
      }
      out.add(TextSpan(text: content, style: style));
      if (i < lines.length - 1) out.add(const TextSpan(text: '\n'));
    }
    return TextSpan(style: style, children: out);
  }

  Widget _box(BuildContext c, bool checked) => Container(
    margin: const EdgeInsets.only(right: 6, bottom: 2),
    width: 18, height: 18,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Theme.of(c).colorScheme.primary, width: 2),
      color: checked ? Theme.of(c).colorScheme.primary : Colors.transparent,
    ),
    child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
  );

  int currentLineIndex(TextSelection sel) =>
      text.substring(0, sel.baseOffset.clamp(0, text.length)).split('\n').length - 1;

  void ensureChecklistAtLine(int lineIdx) {
  final lines = text.split('\n');
  if (lineIdx < 0 || lineIdx >= lines.length) return;

  // já tem token → não faz nada
  if (_reTok.hasMatch(lines[lineIdx])) return;


  // insere token no início da linha
  lines[lineIdx] = '$_kTok0${lines[lineIdx]}';
  final newText = lines.join('\n');

  // posição final = fim da linha anterior (mantém o cursor visualmente igual)
  final lineStart = _lineStartOffset(newText, lineIdx);
  final lineEnd = newText.indexOf('\n', lineStart);
  final newCaret = lineEnd == -1 ? newText.length : lineEnd;

  value = value.copyWith(
    text: newText,
    selection: TextSelection.collapsed(offset: newCaret),
  );
}


  void toggleAtLine(int idx) {
  final lines = text.split('\n');
  if (idx < 0 || idx >= lines.length) return;

  final sel = selection;
  final caretBefore = sel.baseOffset;

  // guarda o comprimento da linha antes da modificação
  final beforeLen = lines[idx].length;

  // alterna token
  if (lines[idx].startsWith(_kTok0)) {
    lines[idx] = lines[idx].replaceFirst(_kTok0, _kTok1);
  } else if (lines[idx].startsWith(_kTok1)) {
    lines[idx] = lines[idx].replaceFirst(_kTok1, _kTok0);
  } else {
    lines[idx] = '$_kTok0${lines[idx]}';
  }

  final newText = lines.join('\n');

  // tenta manter o cursor na mesma posição relativa ao fim da linha
  _lineStartOffset(newText, idx);
  final diff = lines[idx].length - beforeLen;
  final newCaret = (caretBefore + diff).clamp(0, newText.length);

  value = value.copyWith(
    text: newText,
    selection: TextSelection.collapsed(offset: newCaret),
  );
}


  int _lineStartOffset(String t, int lineIdx) {
    var off = 0, i = 0;
    while (i < lineIdx && off < t.length) {
      final n = t.indexOf('\n', off);
      if (n == -1) return t.length;
      off = n + 1; i++;
    }
    return off;
  }
}

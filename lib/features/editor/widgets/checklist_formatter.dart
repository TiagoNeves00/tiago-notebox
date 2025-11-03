import 'package:flutter/services.dart';

const _kTok0 = '[[chk:0]] ';
final  _reTok = RegExp(r'^\[\[chk:(0|1)\]\]\s');

class ChecklistFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    final oldT = oldV.text, newT = newV.text;
    final sel = newV.selection;

    // 1) Não permitir caret dentro do token
    final lineStart = _lineStart(newT, sel.baseOffset);
    final line = _lineAt(newT, lineStart);
    final m = _reTok.firstMatch(line);
    if (m != null) {
      final tokenEnd = lineStart + m.end;
      if (sel.baseOffset < tokenEnd) {
        return newV.copyWith(selection: TextSelection.collapsed(offset: tokenEnd));
      }
    }

    // 2) Backspace a seguir ao token remove-o
    final backspace = newT.length + 1 == oldT.length && sel.isCollapsed;
    if (backspace && m != null) {
      final tokenEnd = lineStart + m.end;
      if (sel.baseOffset == tokenEnd) {
        final t = newT.replaceRange(lineStart, tokenEnd, '');
        return newV.copyWith(
          text: t,
          selection: TextSelection.collapsed(offset: lineStart),
        );
      }
    }

    // 3) Enter: propaga token para nova linha
    final enterInserted = newT.length == oldT.length + 1 &&
        sel.isCollapsed &&
        sel.baseOffset > 0 &&
        newT[sel.baseOffset - 1] == '\n';
    if (enterInserted) {
      final prevLineStart = _prevLineStart(newT, sel.baseOffset - 1);
      final prevLine = _lineAt(newT, prevLineStart);
      final had = _reTok.hasMatch(prevLine);
      if (had) {
        final ins = '$_kTok0';
        final t = newT.replaceRange(sel.baseOffset, sel.baseOffset, ins);
        final caret = sel.baseOffset + ins.length;
        return newV.copyWith(
          text: t,
          selection: TextSelection.collapsed(offset: caret),
        );
      }
    }

    return newV;
  }

  int _lineStart(String t, int off) => t.lastIndexOf('\n', (off - 1).clamp(0, t.length)) + 1;
  int _prevLineStart(String t, int off) => t.lastIndexOf('\n', (off - 1).clamp(0, t.length - 1)) + 1;
  String _lineAt(String t, int start) {
    final n = t.indexOf('\n', start);
    return n == -1 ? t.substring(start) : t.substring(start, n);
  }
}

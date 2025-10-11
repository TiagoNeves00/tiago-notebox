import 'package:flutter/material.dart';

class MarkdownController extends TextEditingController {
  MarkdownController({super.text});
  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, bool? withComposing}) {
    final s = text;
    final List<TextSpan> spans = [];
    final bold = RegExp(r'\*\*(.+?)\*\*');
    int idx = 0;
    for (final m in bold.allMatches(s)) {
      if (m.start > idx) spans.add(TextSpan(text: s.substring(idx, m.start)));
      spans.add(TextSpan(text: m.group(1)!, style: const TextStyle(fontWeight: FontWeight.w700)));
      idx = m.end;
    }
    if (idx < s.length) spans.add(TextSpan(text: s.substring(idx)));
    return TextSpan(style: style, children: spans);
  }
}
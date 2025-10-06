import 'package:flutter/widgets.dart';
import 'package:notebox/features/editor/note_blocks.dart';

/// Divide um TextBlock no cursor: LEFT (antes) e RIGHT (depois)
({TextBlock left, TextBlock right}) splitTextBlockAtCursor(
  TextBlock src,
  TextEditingController c,
) {
  final sel = c.selection;
  final i = sel.isValid ? sel.baseOffset : src.text.length;
  final l = src.text.substring(0, i);
  final r = src.text.substring(i);
  final left = TextBlock(
    l,
    heading: src.heading,
    checklist: src.checklist,
    checked: src.checked,
  );
  final right = TextBlock(
    r,
    heading: src.heading,
    checklist: src.checklist,
    checked: false,
  );
  return (left: left, right: right);
}

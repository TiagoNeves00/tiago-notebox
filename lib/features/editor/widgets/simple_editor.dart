import 'package:flutter/material.dart';

/// Editor simples que suporta texto multiline e spans com ícones inline.
class SimpleEditor extends StatefulWidget {
  final TextEditingController controller;
  const SimpleEditor({super.key, required this.controller});

  @override
  State<SimpleEditor> createState() => _SimpleEditorState();
}

class _SimpleEditorState extends State<SimpleEditor> {
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditableText(
      controller: widget.controller,
      focusNode: _focus,
      style: const TextStyle(fontSize: 18, color: Colors.white),
      cursorColor: Colors.tealAccent,
      backgroundCursorColor: Colors.transparent,
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );
  }
}

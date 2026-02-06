import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RichNoteEditor extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;

  final TextStyle textStyle;
  final Color cursorColor;

  const RichNoteEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.textStyle,
    required this.cursorColor,
  });

  @override
  Widget build(BuildContext context) {
    final base = DefaultStyles.getInstance(context);

    // Valores default se não vierem no textStyle
    final fontSize = textStyle.fontSize ?? 18;
    final lineHeight = textStyle.height ?? 1.45;

    // paragraph = estilo base do “texto normal”
    final baseParagraph = base.paragraph;
    final newParagraph = baseParagraph?.copyWith(
            style: baseParagraph.style.copyWith(
              fontSize: fontSize,
              height: lineHeight,
              fontWeight: textStyle.fontWeight,
              letterSpacing: textStyle.letterSpacing,
            ),
          );

    final custom = newParagraph == null
        ? base
        : base.merge(
            DefaultStyles(
              paragraph: newParagraph,
              // Se quiseres, podes também alinhar listas/quotes etc depois.
            ),
          );

    return QuillEditor.basic(
      controller: controller,
      focusNode: focusNode,
      scrollController: scrollController,
      config: QuillEditorConfig(
        scrollable: true,
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,

        // aplica tamanho/altura do “texto normal”
        customStyles: custom,

        // cursor + seleção
        textSelectionThemeData: TextSelectionThemeData(
          cursorColor: cursorColor,
          selectionColor: cursorColor.withOpacity(0.30),
          selectionHandleColor: cursorColor,
        ),
      ),
    );
  }
}

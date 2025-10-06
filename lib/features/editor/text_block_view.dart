import 'package:flutter/material.dart';
import 'package:notebox/features/editor/note_blocks.dart';

class TextBlockView extends StatefulWidget {
  final TextBlock block;
  final ValueChanged<String> onChanged;
  final VoidCallback onEnterNewBlock;
  const TextBlockView({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onEnterNewBlock,
  });

  @override
  State<TextBlockView> createState() => _TextBlockViewState();
}

class _TextBlockViewState extends State<TextBlockView> {
  late final _c = TextEditingController(text: widget.block.text);

  @override
  void didUpdateWidget(covariant TextBlockView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.text != widget.block.text) {
      _c.value = _c.value.copyWith(
        text: widget.block.text,
        selection: TextSelection.collapsed(offset: widget.block.text.length),
      );
    }
  }

  TextStyle _style(BuildContext context) {
    final c = Theme.of(context);
    switch (widget.block.heading) {
      case 1: return c.textTheme.titleLarge!.copyWith(
        fontSize: 28, fontWeight: FontWeight.w900, color: c.colorScheme.onSurface);
      case 2: return c.textTheme.titleMedium!.copyWith(
        fontSize: 24, fontWeight: FontWeight.w800, color: c.colorScheme.onSurface);
      case 3: return c.textTheme.titleSmall!.copyWith(
        fontSize: 20, fontWeight: FontWeight.w700, color: c.colorScheme.onSurface);
      default: return c.textTheme.bodyLarge!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      maxLines: null,
      style: _style(context),
      decoration: const InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
      ),
      onChanged: (t) {
        widget.block.text = t;
        widget.onChanged(t);
      },
      onSubmitted: (_) => widget.onEnterNewBlock(),
      textInputAction: TextInputAction.newline,
    );
  }
}

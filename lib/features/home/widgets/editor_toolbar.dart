import 'package:flutter/material.dart';

class EditorToolbar extends StatelessWidget {
  final bool visible;
  final VoidCallback? onChecklist;
  final VoidCallback? onImage;
  const EditorToolbar({super.key, required this.visible, this.onChecklist, this.onImage});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: visible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: visible ? 1 : 0,
        child: SafeArea(
          top: false,
          child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF1A0726).withOpacity(0.85),
            child: Row(children: [
              Expanded(child: Center(
                child: IconButton(icon: const Icon(Icons.image_outlined), color: c, onPressed: onImage),
              )),
              Container(width: 1, height: 24, color: c.withOpacity(0.3)),
              Expanded(child: Center(
                child: IconButton(icon: const Icon(Icons.checklist_outlined), color: c, onPressed: onChecklist),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

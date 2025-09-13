import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotesTasksTabs extends StatelessWidget {
  final bool isNotes;
  const NotesTasksTabs({super.key, required this.isNotes});

  @override
  Widget build(BuildContext context) {
    const color = Color.fromARGB(255, 234, 0, 255);
    final base = Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w700,
        );

    // medir textos
    final notesW = _textWidth('Notes', base, context);
    final tasksW = _textWidth('Tasks', base, context);

    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => context.go('/notes'),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 24, top: 10),
                  child: Text('Notes', style: base),
                ),
              ),
              InkWell(
                onTap: () => context.go('/tasks'),
                child: Padding(
                  padding: const EdgeInsets.only(right: 24, top: 10),
                  child: Text('Tasks', style: base),
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            left: isNotes ? 16 : (16 + notesW + 24),
            bottom: 0,
            width: isNotes ? notesW : tasksW,
            height: 3,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _textWidth(String text, TextStyle style, BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    return tp.width;
  }
}
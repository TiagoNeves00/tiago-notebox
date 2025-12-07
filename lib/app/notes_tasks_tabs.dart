// lib/app/notes_tasks_tabs.dart

import 'package:flutter/material.dart';

class NotesTasksTabs extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onSelect;

  const NotesTasksTabs({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFEA00FF);

    Widget tab(String label, int i) {
      final selected = i == currentIndex;
      return GestureDetector(
        onTap: () => onSelect(i),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              height: 4,
              width: selected ? 42 : 0,
              decoration: BoxDecoration(
                color: pink,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        tab("Notes", 0),
        const SizedBox(width: 32),
        tab("Tasks", 1),
      ],
    );
  }
}

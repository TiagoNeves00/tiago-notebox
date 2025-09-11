

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/data/local/db.dart';

final _palette = <int>[
  0xFFB3E5FC, 0xFFFFF59D, 0xFFC8E6C9, 0xFFD1C4E9, 0xFFFFCCBC, 0xFFFFFDE7
];

Color folderColor(int? folderId) {
  if (folderId == null) return const Color(0xFFE0E0E0);
  return Color(_palette[folderId % _palette.length]);
}

class NoteGrid extends StatelessWidget {
  final List<Note> notes;
  const NoteGrid({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: notes.length,
      itemBuilder: (context, i) {   // <── usar context aqui
        final n = notes[i];
        final c = n.color != null ? Color(n.color!) : folderColor(n.folderId);
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: c, width: 1.6),
          ),
          child: InkWell(
            onTap: () => context.push('/edit/${n.id}'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      n.body,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
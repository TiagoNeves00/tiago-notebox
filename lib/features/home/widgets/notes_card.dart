import 'package:flutter/material.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/features/home/widgets/note_grid.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = note.color != null ? Color(note.color!) : folderColor(note.folderId);
    final bg = c.withOpacity(0.32);

    return Card(
      elevation: 0,
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // faixa esquerda
            Container(
              width: 10,
              decoration: BoxDecoration(
                color: c,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              ),
            ),
            // conteúdo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        note.body,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
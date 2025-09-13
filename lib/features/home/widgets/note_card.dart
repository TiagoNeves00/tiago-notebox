import 'package:flutter/material.dart';
import 'package:notebox/data/local/db.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Color color; // cor já resolvida fora

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(0.42);

    return Card(
      elevation: 0,
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // faixa esquerda
            Container(
              width: 6,
              decoration: BoxDecoration(
              color: Color.lerp(color, Colors.black, 0.1),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            // conteúdo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 20),
                      ),
                    ),
                  const SizedBox(height: 12),
                    Divider(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(129, 255, 255, 255)
                      : Colors.black12,
                    thickness: 1.5,
                    height: 3,
                    ),
                  const SizedBox(height: 12),
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
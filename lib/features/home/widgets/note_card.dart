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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? color.withOpacity(0.15) : color.withOpacity(0.5);

    return Card(
      elevation: 0,
      color: bg,
      shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(28),    // bigger left curvature for card
        bottomLeft: Radius.circular(28), // bigger left curvature for card
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      ),
      child: InkWell(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        bottomLeft: Radius.circular(28),
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      onTap: onTap,
      child: Stack(
        children: [
        if (note.bgKey != null)
          Positioned.fill(
          child: Opacity(
            opacity: .25,
            child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              bottomLeft: Radius.circular(28),
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Image.asset(note.bgKey!, fit: BoxFit.cover),
            ),
          ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // faixa esquerda
          Container(
            width: 10, // a bit bigger
            decoration: const BoxDecoration(
            color: Colors.transparent, // color set below
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),    // keep original for faixa
              bottomLeft: Radius.circular(16), // keep original for faixa
              topRight: Radius.circular(16),    // sharp edge
              bottomRight: Radius.circular(16), // sharp edge
            ),
            ),
            child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(color, Colors.black, 0.1),
              borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              ),
            ),
            ),
          ),
          // conteúdo
          Expanded(
            child: Padding(
            padding: const EdgeInsets.all(24),
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
              Flexible(
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
        ],
      ),
      ),
    );
  }
}

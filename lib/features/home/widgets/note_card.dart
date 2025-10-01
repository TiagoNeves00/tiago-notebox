import 'package:flutter/material.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/theme/bg_text_palettes.dart'; // <-- paletas por bg

/// Card com borda neon estática + texto que adapta ao bg via paleta.
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Color color; // ribbon
  final EdgeInsets outerPadding;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.color,
    this.outerPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    const cPink = Color(0xFFEA00FF);
    const radius = 12.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final pal = paletteFor(note.bgKey, Theme.of(context).brightness); // <- cores do texto
    final cardFill = cs.surfaceContainerHighest.withOpacity(isDark ? .92 : .96);

    return Padding(
      padding: outerPadding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius + 2),
          color: Colors.transparent,
          border: Border.all(color: cPink, width: 0.8), // fino
          boxShadow: [BoxShadow(color: cPink.withOpacity(.35), blurRadius: 12)],
        ),
        child: Card(
          elevation: 0,
          color: cardFill,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Stack(children: [
              if (note.bgKey != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: Image(
                      image: ResizeImage(AssetImage(note.bgKey!), width: 1000, height: 1200),
                      fit: BoxFit.cover,
                      color: isDark ? Colors.black26 : Colors.black12,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: pal.title, // <- aplica paleta
                          ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: pal.divider, thickness: 1, height: 2),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        note.body,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: pal.body, // <- aplica paleta
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: -50,
                child: Transform.rotate(
                  angle: 0.9,
                  child: Container(
                    width: 130,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.28 : 0.16),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

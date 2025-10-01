import 'package:flutter/material.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/theme/bg_text_palettes.dart';

/// Borda = cor da pasta  |  Glow = igual ao ChoiceChip selecionado (.35, blur 12)
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Color color; // cor da pasta (borda + glow)
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
    const radius = 12.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final pal = paletteFor(note.bgKey, Theme.of(context).brightness);

    // fundo coerente com tema Neon (sem hardcode)
    final cardFill = cs.surface.withOpacity(isDark ? .92 : .96);

    return Padding(
      padding: outerPadding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius + 2),
          color: Colors.transparent,
          border: Border.all(color: color, width: 0.7),
          boxShadow: [
            BoxShadow(color: color.withOpacity(.35), blurRadius: 12),
          ],
        ),
        child: Card(
          elevation: 0,
          color: cardFill,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Stack(children: [
              if (note.bgKey != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: Image(
                      image: ResizeImage(
                        AssetImage(note.bgKey!),
                        width: 1000,
                        height: 1200,
                      ),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900, color: pal.title),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: pal.divider, thickness: 1, height: 2),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        note.body,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: pal.body),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

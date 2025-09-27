import 'package:flutter/material.dart';
import 'package:notebox/data/local/db.dart';

/// Borda neon ESTÁTICA igual aos ícones (rosa + glow .35, blur 12).
/// Sem animação. Só traço na periferia.
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Color color; // usado só na ribbon
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
    const cPink = Color(0xFFEA00FF); // igual aos ícones
    const radius = 12.0;

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardFill = cs.surfaceContainerHighest.withOpacity(isDark ? .92 : .96);

    return Padding(
      padding: outerPadding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius +  2),
          color: Colors.transparent,
          border: Border.all(color: cPink, width: 0.1), // largura da borda
          boxShadow: [
            BoxShadow(color: cPink.withOpacity(.65), blurRadius: 1), // glow igual aos ícones
          ],
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
                padding: const EdgeInsets.all(18), // ↑/↓ controla “tamanho” do card
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
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color: isDark ? const Color(0x80FFFFFF) : Colors.black12,
                      thickness: 0.7,
                      height: 2,
                    ),
                    const SizedBox(height: 10),
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
              // ribbon fina
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

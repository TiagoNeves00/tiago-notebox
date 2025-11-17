import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/features/home/providers/notes_provider.dart';
import 'package:notebox/theme/bg_text_palettes.dart';

/// Cartão de nota com blur + botão de eliminar no long press.
class NoteCard extends ConsumerStatefulWidget {
  final Note note;
  final VoidCallback onTap;
  final Color color;
  final EdgeInsets outerPadding;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.color,
    this.outerPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  bool _showDelete = false;

  @override
  void didUpdateWidget(NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) _showDelete = false;
  }

  void _handleDelete() async {
    final db = ref.read(dbProvider);
    await (db.delete(db.notes)..where((t) => t.id.equals(widget.note.id))).go();

    // força atualização imediata da lista
    ref.invalidate(notesProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Nota eliminada com sucesso')),
      );
  }

  @override
  Widget build(BuildContext context) {
    const radius = 12.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final pal = paletteFor(widget.note.bgKey, Theme.of(context).brightness);
    final cardFill = cs.surfaceContainerHighest.withOpacity(isDark ? .92 : .96);
    final solid = parseSolid(widget.note.bgKey);

    return Padding(
      padding: widget.outerPadding,
      child: GestureDetector(
        onLongPress: () {
          setState(() => _showDelete = true);
        },
        onTap: () {
          if (_showDelete) {
            setState(() => _showDelete = false);
          } else {
            widget.onTap();
          }
        },
        child: Stack(
          children: [
            // base do cartão
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius + 2),
                color: Colors.transparent,
                border: Border.all(color: widget.color, width: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(.35),
                    blurRadius: 10,
                  ),
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
                  onTap: widget.onTap,
                  child: Stack(
                    children: [
                      if (solid != null)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            child: ColoredBox(color: solid),
                          ),
                        )
                      else if (widget.note.bgKey != null)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            child: Image(
                              image: ResizeImage(
                                AssetImage(widget.note.bgKey!),
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
                              widget.note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: pal.title,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Divider(
                              color: pal.divider,
                              thickness: 1,
                              height: 2,
                            ),
                            const SizedBox(height: 10),
                            Flexible(
                              child: Text(
                                widget.note.body,
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: pal.body),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 🔥 Overlay de eliminação
            if (_showDelete)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedOpacity(
                      opacity: _showDelete ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Container(
                        color: Colors.black.withOpacity(0.55),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                iconSize: 48,
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    useRootNavigator: true,
                                    builder: (dialogCtx) => AlertDialog(
                                      backgroundColor: const Color(0xFF0E1720),
                                      title: const Text(
                                        'Eliminar nota?',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        'Esta ação é irreversível.',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogCtx,
                                            rootNavigator: true,
                                          ).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogCtx,
                                            rootNavigator: true,
                                          ).pop(true),
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    _handleDelete();
                                  } else {
                                    setState(() => _showDelete = false);
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Eliminar nota',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

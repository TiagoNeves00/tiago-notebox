import 'dart:convert';
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

  String _deltaJsonToPlainText(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return raw;

      final sb = StringBuffer();
      for (final op in decoded) {
        if (op is Map && op['insert'] != null) {
          final ins = op['insert'];
          if (ins is String) {
            sb.write(ins);
          } else {
            // embeds (imagem, etc.) -> ignora no preview
          }
        }
      }

      // normaliza quebras para ficar bonito no card
      final txt = sb.toString().replaceAll('\r', '');
      return txt;
    } catch (_) {
      // não é JSON -> assume texto antigo
      return raw;
    }
  }

  String quillBodyToPlainText(String raw) {
    // 1) tenta interpretar como Delta JSON do flutter_quill
    try {
      final decoded = jsonDecode(raw);

      if (decoded is List) {
        final buf = StringBuffer();

        for (final op in decoded) {
          if (op is Map && op.containsKey('insert')) {
            final ins = op['insert'];

            // texto normal
            if (ins is String) {
              buf.write(ins);
            } else {
              // embeds (imagens, etc). não queremos JSON no preview
              // podes trocar por '🖼️' ou '📎' se quiseres indicar que há embed
              // buf.write(' 🖼️ ');
            }
          }
        }

        final s = buf.toString();

        // normaliza: remove \n extra e espaços repetidos
        final normalized = s
            .replaceAll('\r', '')
            .replaceAll('\n', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        return normalized;
      }
    } catch (_) {
      // não é JSON (nota antiga), cai para fallback
    }

    // 2) fallback: texto simples antigo
    return raw
        .replaceAll('\r', '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _previewText(String raw, {int maxChars = 220}) {
    final plain = _deltaJsonToPlainText(raw).trim();
    if (plain.isEmpty) return '';
    // para cards, normalmente fica melhor sem múltiplas linhas gigantes
    final normalized = plain
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    return normalized.length <= maxChars
        ? normalized
        : '${normalized.substring(0, maxChars)}…';
  }

  @override
  Widget build(BuildContext context) {
    const radius = 12.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final pal = paletteFor(widget.note.bgKey, Theme.of(context).brightness);
    final cardFill = cs.surfaceContainerHighest.withOpacity(isDark ? .92 : .96);
    final solid = parseSolid(widget.note.bgKey);

    final preview = quillBodyToPlainText(widget.note.body);

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
                border: Border.all(color: widget.color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(.35),
                    blurRadius: 4,
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
                            Expanded(
                              child: Text(
                                preview,
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

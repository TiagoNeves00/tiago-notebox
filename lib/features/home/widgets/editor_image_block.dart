import 'dart:io';
import 'package:flutter/material.dart';

/// Bloco de imagem com cantos perfeitos + outline neon alinhado
class EditorImageBlock extends StatelessWidget {
  const EditorImageBlock({
    super.key,
    required this.path,
    this.compact = false,
    this.onToggleSize,
    this.onDelete,
    this.neon = const Color(0xFFEA00FF),
    this.radius = 16,
    this.border = 2,
  });

  final String path;
  final bool compact;                 // false = normal | true = pequeno
  final VoidCallback? onToggleSize;   // alterna tamanho
  final VoidCallback? onDelete;       // remove imagem
  final Color neon;
  final double radius;
  final double border;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final imgW = compact ? (w * .55) : (w * .82);
    final imgH = imgW * .75;

    return Center(
      child: SizedBox(
        width: imgW,
        height: imgH,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            // glow suave por fora
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [BoxShadow(color: neon.withOpacity(.28), blurRadius: 10)],
              ),
            ),

            // UM ÚNICO ClipRRect -> imagem + borda = cantos perfeitos
            ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Colors.white), // base neutra
                  Image.file(File(path), fit: BoxFit.cover, filterQuality: FilterQuality.high),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          border: Border.all(color: neon, width: border),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Ações (mostra se quiseres num long-press no pai)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  if (onToggleSize != null)
                    _MiniAction(
                      icon: compact ? Icons.fullscreen : Icons.fullscreen_exit,
                      tooltip: compact ? 'Aumentar' : 'Diminuir',
                      onTap: onToggleSize!,
                    ),
                  const SizedBox(width: 8),
                  if (onDelete != null)
                    _MiniAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Eliminar imagem',
                      onTap: onDelete!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: const Color(0xCC0B0F16),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.check, size: 0, color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}

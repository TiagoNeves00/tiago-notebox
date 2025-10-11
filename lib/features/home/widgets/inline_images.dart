// lib/features/home/widgets/inline_images.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notebox/features/editor/model/image_tokens.dart';

/// Mostra as imagens da nota em coluna, com overlay de ações (ícones apenas)
/// dentro de cada imagem: redimensionar e apagar.
///
/// Tamanhos **reduzidos**:
///  - pequeno: 110 de altura
///  - grande:  170 de altura
class InlineImages extends StatelessWidget {
  const InlineImages({
    super.key,
    required this.images,
    required this.neon,
    required this.onToggleSize,
    required this.onDelete,
  });

  final List<ImgEntry> images;
  final Color neon;
  final void Function(int index) onToggleSize;
  final void Function(int index) onDelete;

  static const _smallH = 110.0;
  static const _largeH = 170.0;
  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < images.length; i++) ...[
          _InlineImageItem(
            path: images[i].path,
            isLarge: images[i].isLarge,
            neon: neon,
            onToggleSize: () => onToggleSize(i),
            onDelete: () => onDelete(i),
          ),
          const SizedBox(height: 14), // mais espaço entre imagem e texto
        ]
      ],
    );
  }
}

class _InlineImageItem extends StatelessWidget {
  const _InlineImageItem({
    required this.path,
    required this.isLarge,
    required this.neon,
    required this.onToggleSize,
    required this.onDelete,
  });

  final String path;
  final bool isLarge;
  final Color neon;
  final VoidCallback onToggleSize;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final h = isLarge ? InlineImages._largeH : InlineImages._smallH;

    return ClipRRect(
      borderRadius: BorderRadius.circular(InlineImages._radius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fundo da imagem
          SizedBox(
            width: double.infinity,
            height: h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                // Outline neon fino perfeitamente alinhado com o clip
                border: Border.all(color: neon, width: 1),
                borderRadius: BorderRadius.circular(InlineImages._radius),
                boxShadow: [
                  BoxShadow(color: neon.withOpacity(.28), blurRadius: 10),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(InlineImages._radius - 0.5),
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0x11000000),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
          ),

          // Overlay de ações (dentro da própria imagem)
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NeonRoundIcon(
                  icon: isLarge ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  neon: neon,
                  onTap: onToggleSize,
                ),
                const SizedBox(width: 8),
                _NeonRoundIcon(
                  icon: Icons.delete_forever_rounded,
                  neon: neon,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonRoundIcon extends StatelessWidget {
  const _NeonRoundIcon({
    required this.icon,
    required this.neon,
    required this.onTap,
  });

  final IconData icon;
  final Color neon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Botão circular, sem texto, com leve brilho neon
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A1119).withOpacity(.60),
            border: Border.all(color: neon, width: 1),
            boxShadow: [
              BoxShadow(color: neon.withOpacity(.30), blurRadius: 10),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.circle, size: 0), // placeholder para manter altura
          ),
        ),
      ),
    ).buildIcon(icon, neon);
  }
}

extension on Widget {
  /// Helper para desenhar o ícone por cima do "chip" redondo acima.
  Widget buildIcon(IconData icon, Color neon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        this,
        Icon(icon, size: 18, color: Colors.white),
      ],
    );
  }
}

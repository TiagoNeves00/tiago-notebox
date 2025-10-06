import 'dart:io';
import 'package:flutter/material.dart';

class ImageBlockView extends StatelessWidget {
  final String path;
  const ImageBlockView({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFFEA00FF);
    final isFile = path.startsWith('/') || path.startsWith('file:');
    final img = isFile ? Image.file(File(path), fit: BoxFit.cover)
                       : Image.asset(path, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: neon.withOpacity(.6), width: .8),
          boxShadow: [BoxShadow(color: neon.withOpacity(.35), blurRadius: 12)],
          borderRadius: BorderRadius.circular(14),
        ),
        child: AspectRatio(aspectRatio: 16/9, child: img),
      ),
    );
  }
}

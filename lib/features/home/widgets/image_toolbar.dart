import 'package:flutter/material.dart';

class OnlyImageToolbar extends StatelessWidget {
  final VoidCallback onPickImage;
  const OnlyImageToolbar({super.key, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFEA00FF);
    final bg = const Color(0xFF0E1720).withOpacity(.92);
    final border = const Color(0xFF00F5FF).withOpacity(.35);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 1)),
        boxShadow: [BoxShadow(color: pink.withOpacity(.22), blurRadius: 18)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: pink.withOpacity(.35), blurRadius: 12)],
              ),
              child: const Icon(Icons.image_outlined, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AudioBlockView extends StatefulWidget {
  final String path;
  final int durationMs;
  final VoidCallback onDelete;
  const AudioBlockView({
    super.key,
    required this.path,
    required this.durationMs,
    required this.onDelete,
  });

  @override
  State<AudioBlockView> createState() => _AudioBlockViewState();
}

class _AudioBlockViewState extends State<AudioBlockView> {
  bool playing = false;
  double pos = 0; // 0..1 (mock de player)

  String _fmt(int ms) {
    final d = Duration(milliseconds: (widget.durationMs * pos).toInt());
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFEA00FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1720).withOpacity(.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pink.withOpacity(.45)),
        boxShadow: [BoxShadow(color: pink.withOpacity(.25), blurRadius: 12)],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
            onPressed: () => setState(() => playing = !playing),
          ),
          Text(_fmt(widget.durationMs),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          Expanded(
            child: Slider(
              value: pos,
              onChanged: (v) => setState(() => pos = v),
              activeColor: pink,
              inactiveColor: pink.withOpacity(.25),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

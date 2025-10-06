// lib/features/editor/widgets/audio_inline_player.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as just;
import 'package:notebox/features/editor/note_blocks.dart';

class AudioInlinePlayer extends StatefulWidget {
  final AudioBlock block;
  final VoidCallback onDelete;
  const AudioInlinePlayer({
    super.key,
    required this.block,
    required this.onDelete,
  });

  @override
  State<AudioInlinePlayer> createState() => _AudioInlinePlayerState();
}

class _AudioInlinePlayerState extends State<AudioInlinePlayer> {
  late final just.AudioPlayer _player = just.AudioPlayer();
  Duration _pos = Duration.zero;
  Duration _dur = const Duration(milliseconds: 1);

  @override
  void initState() {
    super.initState();
    () async {
      await _player.setFilePath(widget.block.path);
      _dur = await _player.duration ??
          Duration(milliseconds: widget.block.durationMs);
      if (mounted) setState(() {});
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _pos = p);
      });
    }();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFFEA00FF);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1119),
        border: Border.all(color: neon, width: .9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: neon.withOpacity(.35), blurRadius: 12)],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _player.playing ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () =>
                _player.playing ? _player.pause() : _player.play(),
          ),
          Expanded(
            child: Slider(
              value: _pos.inMilliseconds
                  .clamp(0, _dur.inMilliseconds)
                  .toDouble(),
              min: 0,
              max: _dur.inMilliseconds.toDouble(),
              onChanged: (v) =>
                  _player.seek(Duration(milliseconds: v.toInt())),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white70),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

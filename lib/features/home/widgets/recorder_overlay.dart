// lib/features/editor/widgets/recorder_overlay.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as rec; // <- alias evita colisão com dart:core Record

typedef OnFinish = void Function(String path, int durationMs);

class RecorderOverlay extends StatefulWidget {
  final OnFinish onFinish;
  const RecorderOverlay({super.key, required this.onFinish});

  @override
  State<RecorderOverlay> createState() => _RecorderOverlayState();
}

class _RecorderOverlayState extends State<RecorderOverlay> {
  // API nova do package:record v5+
  late final rec.AudioRecorder _rec = rec.AudioRecorder();
  bool _recording = false;
  DateTime? _startedAt;

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  Future<String> _tempFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/note_audio_$ts.m4a';
  }

  Future<void> _start() async {
    if (!await _rec.hasPermission()) return;
    final path = await _tempFilePath();
    // Config AAC/M4A cross-plataforma
    await _rec.start(
      rec.RecordConfig(
        encoder: rec.AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
    setState(() {
      _recording = true;
      _startedAt = DateTime.now();
    });
  }

  Future<void> _stop() async {
    final path = await _rec.stop(); // devolve o caminho final
    if (path == null) return;
    final ms = DateTime.now().difference(_startedAt ?? DateTime.now()).inMilliseconds;
    widget.onFinish(path, ms);
    if (mounted) Navigator.of(context).pop(); // fecha overlay
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFFEA00FF);
    return Material(
      color: Colors.black.withOpacity(.5),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1720),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: neon, width: 1),
            boxShadow: [BoxShadow(color: neon.withOpacity(.35), blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gravar áudio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              // Indicador simples
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 160,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: _recording ? neon.withOpacity(.18) : const Color(0xFF0A1119),
                  border: Border.all(color: neon, width: 1),
                  boxShadow: _recording ? [BoxShadow(color: neon.withOpacity(.35), blurRadius: 12)] : const [],
                ),
                child: Text(
                  _recording ? 'A gravar…' : 'Pronto',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_recording)
                    FilledButton(
                      onPressed: _start,
                      child: const Text('Começar'),
                    )
                  else
                    FilledButton.tonal(
                      onPressed: _stop,
                      child: const Text('Parar e guardar'),
                    ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

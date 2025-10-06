import 'dart:convert';

/// Modelo de blocos da nota + (de)serialização JSON
abstract class NoteBlock {
  const NoteBlock();

  Map<String, dynamic> toJson();

  static String encode(List<NoteBlock> blocks) =>
      jsonEncode(blocks.map((b) => b.toJson()).toList());

  static List<NoteBlock> decode(String body) {
    try {
      final raw = jsonDecode(body);
      if (raw is! List) return [TextBlock(body)];
      return raw.map<NoteBlock>((e) {
        final m = Map<String, dynamic>.from(e as Map);
        switch (m['type']) {
          case 'text':
            return TextBlock(
              m['text'] as String? ?? '',
              heading: m['heading'] as int? ?? 0,
              checklist: m['checklist'] as bool? ?? false,
              checked: m['checked'] as bool? ?? false,
            );
          case 'image':
            return ImageBlock(m['path'] as String);
          case 'audio':
            return AudioBlock(
              path: m['path'] as String,
              durationMs: m['durationMs'] as int? ?? 0,
            );
          default:
            return TextBlock(m['text'] as String? ?? '');
        }
      }).toList();
    } catch (_) {
      // Fallback: corpo antigo texto puro
      return [TextBlock(body)];
    }
  }
}

class TextBlock extends NoteBlock {
  String text;
  int heading; // 0=normal, 1=H1, 2=H2, 3=H3
  bool checklist;
  bool checked;

  TextBlock(
    this.text, {
    this.heading = 0,
    this.checklist = false,
    this.checked = false,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'text',
        'text': text,
        'heading': heading,
        'checklist': checklist,
        'checked': checked,
      };
}

class ImageBlock extends NoteBlock {
  final String path;
  ImageBlock(this.path);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'path': path,
      };
}

class AudioBlock extends NoteBlock {
  final String path;
  final int durationMs;
  AudioBlock({required this.path, required this.durationMs});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'audio',
        'path': path,
        'durationMs': durationMs,
      };
}

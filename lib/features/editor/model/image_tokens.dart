import 'dart:convert';

const kImgPrefix = '[[img:';
const kImgSuffix = ']]';

class ImgEntry {
  ImgEntry(this.path, this.isLarge);
  final String path;
  bool isLarge;

  @override
  String toString() => '$kImgPrefix$path|${isLarge ? 'L' : 'S'}$kImgSuffix';

  static ImgEntry? parse(String line) {
    if (!line.startsWith(kImgPrefix) || !line.endsWith(kImgSuffix)) return null;
    final inside = line.substring(kImgPrefix.length, line.length - kImgSuffix.length);
    final parts = inside.split('|');
    if (parts.isEmpty) return null;
    final p = parts.first;
    final size = parts.length > 1 ? parts[1] : 'S';
    return ImgEntry(p, size == 'L');
  }
}

String stripImgTokensFromBody(String body) {
  final lines = const LineSplitter().convert(body);
  final visible = lines.where((l) => ImgEntry.parse(l) == null).toList();
  return visible.join('\n');
}

List<ImgEntry> parseImgTokens(String body) {
  final lines = const LineSplitter().convert(body);
  return lines.map(ImgEntry.parse).whereType<ImgEntry>().toList();
}

String composeBody(String visible, List<ImgEntry> imgs) {
  final buf = StringBuffer(visible.trimRight());
  if (imgs.isNotEmpty) {
    buf.writeln();
    for (final e in imgs) {
      buf.writeln(e.toString());
    }
  }
  return buf.toString();
}

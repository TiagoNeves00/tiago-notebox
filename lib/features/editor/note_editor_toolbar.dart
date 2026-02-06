// lib/features/editor/widgets/note_editor_toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditorToolbar extends StatelessWidget {
  final QuillController controller;

  // Design knobs
  final Color neon;
  final Color surface;
  final Color border;
  final Color icon;
  final Color iconDisabled;

  // Callbacks (ex: abrir bottom sheet de backgrounds)
  final VoidCallback? onPickBackground;

  const NoteEditorToolbar({
    super.key,
    required this.controller,
    this.onPickBackground,
    this.neon = const Color(0xFFEA00FF),
    this.surface = const Color(0xFF0A1119),
    this.border = const Color(0x332C3A4A),
    this.icon = const Color(0xFFEFEFF1),
    this.iconDisabled = const Color(0xFF6B7686),
  });

  bool _isToggled(Attribute attr) {
    return controller.getSelectionStyle().attributes.containsKey(attr.key);
  }

  void _toggle(Attribute attr) {
    final toggled = _isToggled(attr);
    controller.formatSelection(toggled ? Attribute.clone(attr, null) : attr);
  }

  Future<void> _setLink(BuildContext context) async {
    final existing = controller.getSelectionStyle().attributes[Attribute.link.key]?.value;
    final c = TextEditingController(text: existing?.toString() ?? '');
    final url = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0E1720),
        title: const Text('Link', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'https://...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );

    if (url == null) return;

    final v = url.trim();
    if (v.isEmpty) {
      controller.formatSelection(LinkAttribute(null));
    } else {
      controller.formatSelection(LinkAttribute(v));
    }
  }

  Widget _btn({
    required IconData iconData,
    required VoidCallback onTap,
    bool toggled = false,
    String? tooltip,
  }) {
    final fill = toggled ? neon.withOpacity(.18) : Colors.transparent;
    final stroke = toggled ? neon.withOpacity(.55) : border;

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: stroke, width: 1),
            boxShadow: toggled
                ? [BoxShadow(color: neon.withOpacity(.25), blurRadius: 10)]
                : const [],
          ),
          child: Icon(iconData, size: 20, color: toggled ? neon : icon),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 26,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: border,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: surface.withOpacity(.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 18)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return Row(
              children: [
                _btn(
                  iconData: Icons.format_bold,
                  tooltip: 'Bold',
                  toggled: _isToggled(Attribute.bold),
                  onTap: () => _toggle(Attribute.bold),
                ),
                const SizedBox(width: 8),
                _btn(
                  iconData: Icons.format_italic,
                  tooltip: 'Italic',
                  toggled: _isToggled(Attribute.italic),
                  onTap: () => _toggle(Attribute.italic),
                ),
                const SizedBox(width: 8),
                _btn(
                  iconData: Icons.format_underline,
                  tooltip: 'Underline',
                  toggled: _isToggled(Attribute.underline),
                  onTap: () => _toggle(Attribute.underline),
                ),
                const SizedBox(width: 8),
                _btn(
                  iconData: Icons.format_strikethrough,
                  tooltip: 'Strike',
                  toggled: _isToggled(Attribute.strikeThrough),
                  onTap: () => _toggle(Attribute.strikeThrough),
                ),

                _divider(),

                _btn(
                  iconData: Icons.format_list_bulleted,
                  tooltip: 'Bullets',
                  toggled: _isToggled(Attribute.ul),
                  onTap: () => _toggle(Attribute.ul),
                ),
                const SizedBox(width: 8),
                _btn(
                  iconData: Icons.format_list_numbered,
                  tooltip: 'Numbered',
                  toggled: _isToggled(Attribute.ol),
                  onTap: () => _toggle(Attribute.ol),
                ),

                _divider(),

                _btn(
                  iconData: Icons.format_quote,
                  tooltip: 'Quote',
                  toggled: _isToggled(Attribute.blockQuote),
                  onTap: () => _toggle(Attribute.blockQuote),
                ),
                const SizedBox(width: 8),
                _btn(
                  iconData: Icons.code,
                  tooltip: 'Code block',
                  toggled: _isToggled(Attribute.codeBlock),
                  onTap: () => _toggle(Attribute.codeBlock),
                ),

                _divider(),

                _btn(
                  iconData: Icons.title,
                  tooltip: 'H1',
                  toggled: _isToggled(Attribute.h1),
                  onTap: () => _toggle(Attribute.h1),
                ),
                const SizedBox(width: 8),
                _btn(
                  iconData: Icons.text_fields,
                  tooltip: 'H2',
                  toggled: _isToggled(Attribute.h2),
                  onTap: () => _toggle(Attribute.h2),
                ),
                const SizedBox(width: 8),
                _btn(
                  iconData: Icons.subject,
                  tooltip: 'Normal',
                  toggled: _isToggled(Attribute.h1) || _isToggled(Attribute.h2),
                  onTap: () {
                    controller.formatSelection(Attribute.header);
                  },
                ),

                _divider(),

                _btn(
                  iconData: Icons.link,
                  tooltip: 'Link',
                  toggled: _isToggled(Attribute.link),
                  onTap: () => _setLink(context),
                ),

                _divider(),

                _btn(
                  iconData: Icons.wallpaper,
                  tooltip: 'Background',
                  toggled: false,
                  onTap: () => onPickBackground?.call(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

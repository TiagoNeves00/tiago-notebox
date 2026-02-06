import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notebox/features/home/widgets/neon_icon_button.dart';

class NeonQuillToolbar extends StatefulWidget {
  final QuillController controller;
  final VoidCallback? onPickBackground;

  const NeonQuillToolbar({
    super.key,
    required this.controller,
    this.onPickBackground,
  });

  @override
  State<NeonQuillToolbar> createState() => _NeonQuillToolbarState();
}

class _NeonQuillToolbarState extends State<NeonQuillToolbar> {
  static const glowPink = Color(0xFFEA00FF);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCtrlChanged);
  }

  @override
  void didUpdateWidget(covariant NeonQuillToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onCtrlChanged);
      widget.controller.addListener(_onCtrlChanged);
    }
  }

  void _onCtrlChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCtrlChanged);
    super.dispose();
  }

  bool _has(Attribute a) {
    final attrs = widget.controller.getSelectionStyle().attributes;
    return attrs.containsKey(a.key);
  }

  void _toggle(Attribute a) {
    final enabled = _has(a);
    widget.controller.formatSelection(enabled ? Attribute.clone(a, null) : a);
  }

  // Link remove: LinkAttribute(null)
  void _removeLink() => widget.controller.formatSelection(LinkAttribute(null));

  Widget _btn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool active = false,
  }) {
    return Opacity(
      opacity: active ? 1 : 0.75,
      child: NeonIconButton(
        icon: icon,
        tooltip: tooltip,
        glow: glowPink.withOpacity(active ? 0.75 : 0.35),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBold = _has(Attribute.bold);
    final isItalic = _has(Attribute.italic);
    final isUnderline = _has(Attribute.underline);
    final isStrike = _has(Attribute.strikeThrough);

    final buttons = <Widget>[
      if (widget.onPickBackground != null) ...[
        _btn(
          icon: Icons.wallpaper_rounded,
          tooltip: 'Fundo',
          onPressed: widget.onPickBackground!,
        ),
        const SizedBox(width: 10),
      ],

      _btn(
        icon: Icons.format_bold_rounded,
        tooltip: 'Bold',
        active: isBold,
        onPressed: () => _toggle(Attribute.bold),
      ),
      const SizedBox(width: 10),

      _btn(
        icon: Icons.format_italic_rounded,
        tooltip: 'Italic',
        active: isItalic,
        onPressed: () => _toggle(Attribute.italic),
      ),
      const SizedBox(width: 10),

      _btn(
        icon: Icons.format_underline_rounded,
        tooltip: 'Underline',
        active: isUnderline,
        onPressed: () => _toggle(Attribute.underline),
      ),
      const SizedBox(width: 10),

      _btn(
        icon: Icons.strikethrough_s_rounded,
        tooltip: 'Strike',
        active: isStrike,
        onPressed: () => _toggle(Attribute.strikeThrough),
      ),
      const SizedBox(width: 10),

      _btn(
        icon: Icons.link_rounded,
        tooltip: 'Remover link',
        onPressed: _removeLink,
      ),
    ];

    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: buttons,
            ),
          ),
        ),
      ),
    );
  }
}

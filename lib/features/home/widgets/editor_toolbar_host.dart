import 'package:flutter/material.dart';
import 'package:notebox/features/home/widgets/editor_toolbar.dart';

class EditorToolbarHost extends StatefulWidget {
  final VoidCallback? onChecklist;
  final VoidCallback? onImage;
  const EditorToolbarHost({super.key, this.onChecklist, this.onImage});

  @override
  State<EditorToolbarHost> createState() => _EditorToolbarHostState();
}

class _EditorToolbarHostState extends State<EditorToolbarHost> with WidgetsBindingObserver {
  bool _visible = false;
  @override void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override void didChangeMetrics() {
    final b = WidgetsBinding.instance.window.viewInsets.bottom;
    if ((_visible) != (b > 0)) setState(() => _visible = b > 0);
  }

  @override
  Widget build(BuildContext context) {
    return EditorToolbar(visible: _visible, onChecklist: widget.onChecklist, onImage: widget.onImage);
  }
}

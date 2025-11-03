import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Line {
  bool checklist;
  bool checked;
  String text;
  Line({this.checklist = false, this.checked = false, this.text = ''});
}

class LineEditorController {
  _LineEditorState? _state;
  String get text => _state?._lines.map((e) => e.text).join('\n') ?? '';
  void toggleChecklistForFocused() => _state?._toggleChecklistForFocused();
  void setText(String t) => _state?._setText(t);
}

class LineEditor extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onChanged;
  final TextStyle style;
  final LineEditorController? controller;

  const LineEditor({
    super.key,
    required this.initialText,
    required this.onChanged,
    required this.style,
    this.controller,
  });

  @override
  State<LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends State<LineEditor> {
  final _lines = <Line>[];
  final _ctrls = <TextEditingController>[];
  final _focus = <FocusNode>[];
  int _focused = 0;
  String lastValue = '';

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    for (final l in widget.initialText.split('\n')) {
      _addLine(Line(text: l));
    }
    if (_lines.isEmpty) _addLine(Line());
  }

  void _setText(String t) {
    for (final c in _ctrls) c.dispose();
    for (final f in _focus) f.dispose();
    _lines.clear();
    _ctrls.clear();
    _focus.clear();
    final parts = (t.isEmpty ? [''] : t.split('\n'));
    for (final l in parts) _addLine(Line(text: l));
    if (_lines.isEmpty) _addLine(Line());
    _focused = 0;
    setState(() {});
  }

  void _addLine(Line line, {int? at}) {
    final c = TextEditingController(text: line.text);
    final f = FocusNode();
    f.addListener(() {
      if (f.hasFocus) _focused = _focus.indexOf(f);
    });
    if (at == null) {
      _lines.add(line);
      _ctrls.add(c);
      _focus.add(f);
    } else {
      _lines.insert(at, line);
      _ctrls.insert(at, c);
      _focus.insert(at, f);
    }
  }

  void _removeAt(int i) {
    _lines.removeAt(i);
    _ctrls.removeAt(i).dispose();
    _focus.removeAt(i).dispose();
  }

  void _emit() => widget.onChanged(_lines.map((e) => e.text).join('\n'));

  void _toggleChecklistForFocused() {
    setState(() {
      _lines[_focused].checklist = !_lines[_focused].checklist;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final f in _focus) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _lines.length,
      itemBuilder: (ctx, i) {
        final line = _lines[i];
        return Focus(
          onKeyEvent: (node, evt) {
            if (evt is KeyDownEvent &&
                evt.logicalKey == LogicalKeyboardKey.backspace) {
              final sel = _ctrls[i].selection;
              if (sel.isCollapsed && sel.baseOffset == 0) {
                if (line.checklist) {
                  setState(() => line.checklist = false);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _focus.forEach((f) => f.unfocus());
                    _focus[i].requestFocus();
                    _ctrls[i].selection =
                        const TextSelection.collapsed(offset: 0);
                  });
                  _emit();
                  return KeyEventResult.handled;
                } else if (i > 0) {
                  final prev = _ctrls[i - 1];
                  final off = prev.text.length;
                  prev.text += _ctrls[i].text;
                  _removeAt(i);
                  setState(() {});
                  _emit();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _focus.forEach((f) => f.unfocus());
                    _focus[i - 1].requestFocus();
                    prev.selection = TextSelection.collapsed(offset: off);
                  });
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (line.checklist)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      line.checked = !line.checked;
                    });
                    _emit();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                      color: line.checked
                          ? Colors.white
                          : Colors.transparent,
                    ),
                    child: line.checked
                        ? const Icon(Icons.check,
                            size: 18, color: Colors.black)
                        : null,
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrls[i],
                  focusNode: _focus[i],
                  style: widget.style,
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  onChanged: (v) {
                    _lines[i].text = v;
                    _emit();
                    final bool pressedEnter =
                        v.length > lastValue.length && v.endsWith('\n');
                    if (pressedEnter) {
                      final bool shouldInheritChecklist =
                          line.checklist &&
                              v.trim().replaceAll('\n', '').isNotEmpty;
                      final at = (i + 1).clamp(0, _lines.length);
                      _addLine(Line(checklist: shouldInheritChecklist), at: at);
                      setState(() {});
                      _emit();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (at < _focus.length) {
                          _focus.forEach((f) => f.unfocus());
                          _focus[at].requestFocus();
                          _ctrls[at].selection =
                              const TextSelection.collapsed(offset: 0);
                        }
                      });
                    }
                    lastValue = v;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteDraft {
  String title;
  String body;
  int? color;

  NoteDraft({this.title = '', this.body = '', this.color});
}

class EditorCtrl extends Notifier<NoteDraft> {
  final _undo = <NoteDraft>[];
  final _redo = <NoteDraft>[];

  @override
  NoteDraft build() => NoteDraft();
  void load(NoteDraft d) {
    state = d;
    _undo.clear();
    _redo.clear();
  }

  void set({String? title, String? body, int? color}) {
    _undo.add(NoteDraft(title: state.title, body: state.body, color: state.color));
    _redo.clear();
    state = NoteDraft(title: title ?? state.title, body: body ?? state.body, color: color ?? state.color);
  }

  void undo(){ if(_undo.isEmpty)return;
    _redo.add(state); state=_undo.removeLast(); }
  
  void redo(){ if(_redo.isEmpty)return;
    _undo.add(state); state=_redo.removeLast(); }
  
  String snapshotJson()=>jsonEncode({'title':state.title,'body':state.body,'color':state.color});
}
final editorProvider=NotifierProvider<EditorCtrl,NoteDraft>(EditorCtrl.new);


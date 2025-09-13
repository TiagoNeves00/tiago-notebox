import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteDraft {
  final String title;
  final String body;
  final int? color;
  final int? folderId;
  const NoteDraft({this.title = '', this.body = '', this.color, this.folderId});
}

class EditorCtrl extends StateNotifier<NoteDraft> {
  EditorCtrl() : super(const NoteDraft());

  void load(NoteDraft d) => state = d;

  void set({String? title, String? body}) {
    state = NoteDraft(
      title: title ?? state.title,
      body: body ?? state.body,
      color: state.color,
      folderId: state.folderId,
    );
  }

  void setColor(int? v) => state = NoteDraft(
        title: state.title, body: state.body, color: v, folderId: state.folderId);

  void setFolderId(int? v) => state = NoteDraft(
        title: state.title, body: state.body, color: state.color, folderId: v);
}

// PROVIDER CORRETO
final editorProvider =
    StateNotifierProvider<EditorCtrl, NoteDraft>((ref) => EditorCtrl());


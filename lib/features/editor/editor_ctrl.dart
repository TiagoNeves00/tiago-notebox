import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteDraft {
  final String title;
  final String body;
  final int? color;
  final int? folderId;
  final String? bgKey;

  const NoteDraft({
    this.title = '',
    this.body = '',
    this.color,
    this.folderId,
    this.bgKey,
  });
}

class EditorCtrl extends StateNotifier<NoteDraft> {
  EditorCtrl() : super(const NoteDraft());

  void load(NoteDraft d) => state = d;

  void set({String? title, String? body}) {
    // Construção explícita (sem copyWith) para evitar dependências
    state = NoteDraft(
      title: title ?? state.title,
      body: body ?? state.body,
      color: state.color,
      folderId: state.folderId,
      bgKey: state.bgKey,
    );
  }

  void setColor(int? v) => state = NoteDraft(
        title: state.title, body: state.body, color: v, folderId: state.folderId, bgKey: state.bgKey);

  void setFolderId(int? id) {
    state = NoteDraft(
      title: state.title,
      body: state.body,
      color: state.color,
      folderId: id,
      bgKey: state.bgKey,
    );
  }

  void setBg(String? key) {
    state = NoteDraft(
      title: state.title,
      body: state.body,
      color: state.color,
      folderId: state.folderId,
      bgKey: key,
    );
  }
}

// PROVIDER CORRETO
final editorProvider =
    StateNotifierProvider<EditorCtrl, NoteDraft>((ref) => EditorCtrl());


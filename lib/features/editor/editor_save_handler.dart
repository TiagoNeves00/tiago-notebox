import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O NoteEditorPage regista aqui um callback para o AppShell poder chamar "Guardar".
final editorSaveHandlerProvider =
    StateProvider<Future<void> Function()?>((_) => null);
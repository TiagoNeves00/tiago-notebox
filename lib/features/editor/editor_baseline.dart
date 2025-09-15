import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';

final editorBaselineProvider = StateProvider<NoteDraft?>((_) => null);
bool isDirty(NoteDraft a, NoteDraft? b) =>
    b == null ||
    a.title != b.title || a.body != b.body ||
    a.color != b.color || a.folderId != b.folderId || a.bgKey != b.bgKey;
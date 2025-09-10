import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';

class NotesRepo {
  final AppDb db;
  NotesRepo(this.db);

  Stream<List<Note>> watchAll({int? folderId, int? tagId, String? query}) {
    final base = db.select(db.notes)
      ..orderBy([
        (t) => OrderingTerm(expression: t.isFavorite, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    if (folderId != null) base.where((n) => n.folderId.equals(folderId));
    if (query != null && query.isNotEmpty) {
      base.where((n) => n.title.like('%$query%') | n.body.like('%$query%'));
    }
    if (tagId == null) return base.watch();

    final joined = base.join([
      innerJoin(db.noteTags, db.noteTags.noteId.equalsExp(db.notes.id)),
    ])..where(db.noteTags.tagId.equals(tagId));

    return joined.watch().map(
      (rows) => rows.map((r) => r.readTable(db.notes)).toList(),
    );
  }

  Future<int> add(String title, String body, {int? folderId}) {
    return db
        .into(db.notes)
        .insert(
          NotesCompanion.insert(
            title: title,
            body: body,
            folderId: Value(folderId),
          ),
        );
  }
}

final notesRepoProvider = Provider<NotesRepo>((ref) {
  final db = ref.watch(dbProvider);
  return NotesRepo(db);
});

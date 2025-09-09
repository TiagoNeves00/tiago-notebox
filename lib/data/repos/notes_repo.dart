

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';

class NotesRepo {
  final AppDb db;
  NotesRepo(this.db);

  Stream<List<Note>> watchAll({int? folderId, int? tagId, String? query}) {
    final q = db.select(db.notes)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.isFavorite, mode: OrderingMode.desc),
        (tbl) => OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc),
      ]);
    if (folderId != null) {
      q.where((n) => n.folderId.equals(folderId));
    }
    if (query != null && query.isNotEmpty) {
      // FTS5 query simplificada: procurar em title/body
      q.where((n) =>
          n.title.like('%$query%') | n.body.like('%$query%'));
    }
    return q.watch();
  }

  Future<int> add(String title, String body, {int? folderId}) {
    return db.into(db.notes).insert(
          NotesCompanion.insert(title: title, body: body, folderId: Value(folderId)),
        );
  }
}

final notesRepoProvider = Provider<NotesRepo>((ref) {
  final db = ref.watch(dbProvider);
  return NotesRepo(db);
});

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/features/home/providers/filters.dart';

final searchQueryProvider = StateProvider<String>((_) => '');

final notesProvider = StreamProvider((ref) {
  final db = ref.watch(dbProvider);
  final filter = ref.watch(folderFilterProvider);
  final query  = ref.watch(searchQueryProvider).trim();

  final q = db.select(db.notes)
    ..orderBy([
      (t) => OrderingTerm(expression: t.isFavorite, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
    ]);

  // filtro por pasta
  switch (filter) {
    case All():
      break;
    case ById(:final id):
      q.where((t) => t.folderId.equals(id));
      break;
    case Unfiled():
      q.where((t) => t.folderId.isNull());
      break;
  }

  // busca (LIKE; troca para FTS5 quando quiseres)
  if (query.isNotEmpty) {
    final like = '%$query%';
    q.where((t) => t.title.like(like) | t.body.like(like));
  }

  return q.watch();
});

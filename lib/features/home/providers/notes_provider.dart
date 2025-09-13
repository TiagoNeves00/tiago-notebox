import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db_provider.dart';
import 'package:notebox/features/home/providers/filters.dart';

final searchQueryProvider = StateProvider<String>((_) => '');

final notesProvider = StreamProvider((ref) {
  final db = ref.watch(dbProvider);
  final f = ref.watch(folderFilterProvider);
  final q = (db.select(db.notes)
    ..orderBy([(t)=>OrderingTerm.desc(t.isFavorite), (t)=>OrderingTerm.desc(t.updatedAt)]));
  switch (f) {
    case All(): break;
    case ById(:final id): q.where((t)=>t.folderId.equals(id)); break;
    case Unfiled(): q.where((t)=>t.folderId.isNull()); break;
  }
  return q.watch(); // + aplica search se tiveres
});
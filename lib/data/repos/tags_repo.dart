import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';

class TagsRepo {
  final AppDb db;
  TagsRepo(this.db);
  Stream<List<Tag>> watchAll() =>
      (db.select(db.tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
}
final tagsRepoProvider = Provider((ref) => TagsRepo(ref.watch(dbProvider)));

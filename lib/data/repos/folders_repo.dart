import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';

class FoldersRepo {
  final AppDb db;
  FoldersRepo(this.db);
  Stream<List<Folder>> watchAll() => (db.select(db.folders)
        ..orderBy([(f) => OrderingTerm.asc(f.order)]))
      .watch();
}
final foldersRepoProvider = Provider((ref) => FoldersRepo(ref.watch(dbProvider)));

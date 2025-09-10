import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';

class RevisionsRepo {
  final AppDb db; RevisionsRepo(this.db);
  Future<int> add(int noteId, String snap)=> db.into(db.revisions).insert(
    RevisionsCompanion.insert(noteId: noteId, snapshotJson: snap));
}
final revisionsRepoProvider=Provider((ref)=>RevisionsRepo(ref.watch(dbProvider)));

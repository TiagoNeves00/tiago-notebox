import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:notebox/data/local/tables.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

LazyDatabase _openConn() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'notebox.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [Notes, Folders, Tags, NoteTags, Attachments, Trash, Revisions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConn());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(folders, folders.color);
      }
    },
  );
}
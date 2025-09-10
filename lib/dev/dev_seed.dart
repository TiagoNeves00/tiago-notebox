import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/local/db_provider.dart';


Future<void> runDevSeed(WidgetRef ref, {bool force = false}) async {
  final db = ref.read(dbProvider);

  if (!force) {
    final row = await db.customSelect('SELECT COUNT(*) AS c FROM notes').getSingle();
    final count = row.data['c'] as int;
    if (count >= 5) return; // já tens “suficiente”, não semeia
  }

  // opcional: limpar antes de semear quando force=true
  if (force) {
    await db.transaction(() async {
      await db.delete(db.noteTags).go();
      await db.delete(db.attachments).go();
      await db.delete(db.revisions).go();
      await db.delete(db.trash).go();
      await db.delete(db.notes).go();
      await db.delete(db.tags).go();
      await db.delete(db.folders).go();
    });
  }

  if ((await (db.select(db.notes)..limit(1)).get()).isNotEmpty) return;

  final workId   = await db.into(db.folders).insert(FoldersCompanion.insert(name: 'Trabalho', order: const Value(0)));
  final pessoalId= await db.into(db.folders).insert(FoldersCompanion.insert(name: 'Pessoal',  order: const Value(1)));
  final estudosId= await db.into(db.folders).insert(FoldersCompanion.insert(name: 'Estudos',  order: const Value(2)));

  final urgenteId= await db.into(db.tags).insert(TagsCompanion.insert(name: 'urgente'));
  final ideiaId  = await db.into(db.tags).insert(TagsCompanion.insert(name: 'ideia'));

  final n1 = await db.into(db.notes).insert(NotesCompanion.insert(title: 'Reunião sprint', body: 'Pontos A/B/C', folderId: Value(workId), isFavorite: const Value(true)));
  final n2 = await db.into(db.notes).insert(NotesCompanion.insert(title: 'Lista compras', body: 'Leite, ovos, fruta', folderId: Value(pessoalId)));
  final n3 = await db.into(db.notes).insert(NotesCompanion.insert(title: 'Resumo artigo', body: 'Notas de estudo...', folderId: Value(estudosId)));
  final n4 = await db.into(db.notes).insert(NotesCompanion.insert(title: 'Ideias app', body: 'Widgets, grelha, busca', folderId: Value(workId)));
  final n5 = await db.into(db.notes).insert(NotesCompanion.insert(title: 'Treino', body: 'Push/Pull/Legs', folderId: Value(pessoalId), isFavorite: const Value(true)));

  await db.into(db.noteTags).insert(NoteTagsCompanion.insert(noteId: n1, tagId: urgenteId));
  await db.into(db.noteTags).insert(NoteTagsCompanion.insert(noteId: n3, tagId: ideiaId));
  await db.into(db.noteTags).insert(NoteTagsCompanion.insert(noteId: n4, tagId: ideiaId));
}

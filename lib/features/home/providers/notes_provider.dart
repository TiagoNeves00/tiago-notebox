import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/features/home/providers/filters.dart';

final searchQueryProvider = StateProvider<String>((_) => '');

final notesProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(notesRepoProvider);
  final query = ref.watch(searchQueryProvider);
  final folderId = ref.watch(selectedFolderIdProvider);
  final tagId = ref.watch(selectedTagIdProvider);
  return repo.watchAll(folderId: folderId, tagId: tagId, query: query);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/features/home/providers/filters.dart';

final searchQueryProvider = StateProvider<String>((_) => '');

final notesProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(notesRepoProvider);
  final query = ref.watch(searchQueryProvider);
  final folderId = ref.watch(selectedFolderIdProvider);
  return repo.watchAll(folderId: folderId, query: query);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/repos/notes_repo.dart';

final searchQueryProvider = StateProvider<String>((_) => '');

final notesProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(notesRepoProvider);
  final query = ref.watch(searchQueryProvider);
  return repo.watchAll(query: query);
});

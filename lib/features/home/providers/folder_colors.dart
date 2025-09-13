import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/repos/folders_repo.dart';

final folderColorsProvider = StreamProvider<Map<int, int?>>((ref) {
  final repo = ref.watch(foldersRepoProvider);
  return repo.watchAll().map((fs) => {for (final f in fs) f.id: f.color});
});
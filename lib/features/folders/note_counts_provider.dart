import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db_provider.dart';

final noteCountsByFolderProvider = StreamProvider<Map<int,int>>((ref) {
  final db = ref.watch(dbProvider);
  final stream = db.customSelect(
    'SELECT folder_id, COUNT(*) c FROM notes WHERE folder_id IS NOT NULL GROUP BY folder_id',
    readsFrom: {db.notes},
  ).watch();
  return stream.map((rows) {
    final m = <int,int>{};
    for (final r in rows) {
      final data = r.data;
      m[(data['folder_id'] as int)] = (data['c'] as int);
    }
    return m;
  });
});
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class FolderFilter { const FolderFilter(); }
class All extends FolderFilter { const All(); }
class ById extends FolderFilter { final int id; const ById(this.id); }
class Unfiled extends FolderFilter { const Unfiled(); }

final folderFilterProvider =
  StateProvider<FolderFilter>((_) => const All());
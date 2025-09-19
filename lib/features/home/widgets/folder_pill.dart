import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/features/home/providers/folder_colors.dart';

class FolderPill extends ConsumerWidget {
  const FolderPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fg = Theme.of(context).appBarTheme.foregroundColor ?? cs.onSurface;
    final currentId = ref.watch(editorProvider).folderId;
    final colors = ref.watch(folderColorsProvider)
        .maybeWhen(data: (m) => m, orElse: () => const <int,int?>{});
    final folders$ = ref.watch(foldersRepoProvider).watchAll();

    return StreamBuilder<List<Folder>>(
      stream: folders$, builder: (_, snap) {
        final folders = snap.data ?? const <Folder>[];
        final name = currentId == null
            ? 'Sem pasta'
            : folders.firstWhere(
                (f)=>f.id==currentId, orElse: ()=>Folder(id:-1,name:'Pasta',order:0)).name;
        final cInt = currentId!=null ? colors[currentId] : null;
        final dot = cInt!=null ? Color(cInt) : cs.outlineVariant;

        return Semantics(
          button: true,
          label: 'Selecionar pasta',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openPicker(context, ref, currentId),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal:12, vertical:8),
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(.18),
                      border: Border.all(color: fg.withOpacity(.24)),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow:[BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12, offset: const Offset(0,4))],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.folder_open_rounded, size:18, color: fg),
                      const SizedBox(width:6),
                      Container(width:10,height:10,
                        decoration: BoxDecoration(color: dot, shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26, width:1))),
                      const SizedBox(width:6),
                      Text(name, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
                      const SizedBox(width:4),
                      Icon(Icons.expand_more, size:18, color: fg),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openPicker(BuildContext ctx, WidgetRef ref, int? currentId) async {
  final repo = ref.read(foldersRepoProvider);
  final folders = await repo.watchAll().first;
  final colors = ref.read(folderColorsProvider)
      .maybeWhen(data: (m) => m, orElse: () => const <int,int?>{});
  final cs = Theme.of(ctx).colorScheme;

  final selected = currentId ?? -1; // -1 == Sem pasta

  final chosen = await showModalBottomSheet<int?>(
    context: ctx, showDragHandle: true, isScrollControlled: true,
    builder: (sheetCtx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const ListTile(
          title: Text(
            'Escolhe a Pasta: ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Divider(height: 1, thickness: 3, color: cs.onPrimary, indent: 16, endIndent: 16),
        const SizedBox(height: 32),
        Flexible(child: ListView(shrinkWrap: true, children: [
          RadioListTile<int>(
            value: -1, groupValue: selected, // <- sentinela
            title: const Text('Sem pasta'),
            secondary: CircleAvatar(backgroundColor: cs.outlineVariant, radius: 12),
            onChanged: (v) => Navigator.pop(sheetCtx, v),
          ),
          ...folders.map((f) => RadioListTile<int>(
            value: f.id, groupValue: selected,
            title: Text(f.name),
            secondary: CircleAvatar(
              backgroundColor: Color(colors[f.id] ?? cs.outlineVariant.value), radius: 12),
            onChanged: (v) => Navigator.pop(sheetCtx, v),
          )),
        ])),
      ]),
    ),
  );

  if (chosen == null) return;                 // cancelou → não muda
  ref.read(editorProvider.notifier).setFolderId(chosen == -1 ? null : chosen);
}
}

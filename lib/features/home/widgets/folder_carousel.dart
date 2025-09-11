import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/features/home/providers/filters.dart';
import 'package:notebox/features/home/widgets/note_grid.dart';

class FolderCarousel extends ConsumerStatefulWidget {
  const FolderCarousel({super.key});
  @override
  ConsumerState<FolderCarousel> createState() => _FolderCarouselState();
}

class _FolderCarouselState extends ConsumerState<FolderCarousel> {
  late final PageController _ctrl;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: .82)
      ..addListener(() => setState(() => _page = _ctrl.page ?? 0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<List<Folder>> stream =
        ref.watch(foldersRepoProvider).watchAll();

    return SizedBox(
      height: 120,
      child: StreamBuilder<List<Folder>>(
        stream: stream,
        builder: (context, snapshot) {
          final folders = snapshot.data ?? const <Folder>[];
          final total = folders.length + 1; // + "Todas"
          if (total == 1) return const SizedBox.shrink();

          return PageView.builder(
            controller: _ctrl,
            itemCount: total,
            onPageChanged: (i) {
              final id = i == 0 ? null : folders[i - 1].id;
              ref.read(selectedFolderIdProvider.notifier).state = id;
            },
            itemBuilder: (context, i) {
              final isAll = i == 0;
              final String name = isAll ? 'Todas' : folders[i - 1].name;
              final int? id = isAll ? null : folders[i - 1].id;
              final color = folderColor(id);
              final active = (i - _page).abs() < .5;

              return AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: active ? 1 : .95,
                child: Card(
                  color: color.withOpacity(.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: color, width: 1.2),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => ref
                        .read(selectedFolderIdProvider.notifier)
                        .state = id,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          Text(isAll ? 'Todas as notas' : 'Pasta',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
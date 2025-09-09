import 'package:flutter/material.dart';
import 'package:notebox/features/home/mock_data.dart';


class FolderCarousel extends StatefulWidget {
  const FolderCarousel({super.key});
  @override
  State<FolderCarousel> createState() => _FolderCarouselState();
}

class _FolderCarouselState extends State<FolderCarousel> {
  late final PageController _ctrl;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: .82)..addListener(_onScroll);
  }

  void _onScroll() => setState(() => _page = _ctrl.page ?? 0);

  @override
  void dispose() {
    _ctrl
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _ctrl,
        itemCount: foldersMock.length,
        itemBuilder: (_, i) {
          final f = foldersMock[i];
          final active = (i - _page).abs() < .5;
          return AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: active ? 1 : .95,
            child: Card(
              color: f.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {}, // filtrar por pasta na Fase 3
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name, style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text('${f.count} notas', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';

const _bgKeys = [
  'assets/note_bg/old_paper_bg.webp',
  'assets/note_bg/purple_flower_bg.webp',
  'assets/note_bg/blue_ocean_sky_bg.webp',
  'assets/note_bg/orange_water_sky_bg.webp',
  'assets/note_bg/baby_blue_bg.webp',
  'assets/note_bg/dark_night_bg.webp',
  'assets/note_bg/white_bg.webp',
  'assets/note_bg/bridge_low_sun_bg.webp',
  'assets/note_bg/night_city_1_bg.webp',
];

// note_bg_picker.dart
Future<void> showNoteBgPicker(BuildContext c, WidgetRef ref) async {
  final chosen = await showModalBottomSheet<String?>(
    context: c,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: .6, minChildSize: .3, maxChildSize: .95,
      expand: false,
      builder: (ctx, scroll) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Sem fundo'),
              onTap: () => Navigator.pop(ctx, null),
            ),
            Expanded(
              child: GridView.builder(
                controller: scroll,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: _bgKeys.length,
                itemBuilder: (_, i) => InkWell(
                  onTap: () => Navigator.pop(ctx, _bgKeys[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(_bgKeys[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  ref.read(editorProvider.notifier).setBg(chosen);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';
import 'package:notebox/theme/bg_text_palettes.dart';

const _imageBgKeys = [
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

/// Paleta calma com toques neon — guardamos como **chaves sólidas**.
/// Usa SEMPRE o prefixo `solid:` para evitar tentativas de `Image.asset`.
const _solidHex = <String>[
  'solid:#08131D', // deep navy
  'solid:#0C0F17', // graphite blue
  'solid:#17202B', // dark slate
  'solid:#8AD8FF', // soft cyan
  'solid:#61E3CF', // mint neon
  'solid:#A89DFF', // lilac glow
  'solid:#FFA6D8', // pink glow
  'solid:#FFE082', // warm amber
  'solid:#F6F7FB', // near-white
];

Future<void> showNoteBgPicker(BuildContext c, WidgetRef ref) async {
  final chosen = await showModalBottomSheet<String?>(
    context: c,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => DefaultTabController(
      length: 2,
      child: DraggableScrollableSheet(
        initialChildSize: .62,
        minChildSize: .30,
        maxChildSize: .95,
        expand: false,
        builder: (ctx, scroll) => Column(
          children: [
            const TabBar(tabs: [Tab(text: 'Cores'), Tab(text: 'Imagens')]),
            Expanded(
              child: TabBarView(
                children: [
                  // CORES
                  GridView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemCount: _solidHex.length,
                    itemBuilder: (_, i) {
                      final key = _solidHex[i];
                      final color = parseSolid(key) ?? const Color(0xFF101418);
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(ctx, key),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                        ),
                      );
                    },
                  ),

                  // IMAGENS
                  GridView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _imageBgKeys.length,
                    itemBuilder: (_, i) => InkWell(
                      onTap: () => Navigator.pop(ctx, _imageBgKeys[i]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(_imageBgKeys[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Sem fundo'),
              onTap: () => Navigator.pop(ctx, null),
            ),
          ],
        ),
      ),
    ),
  );

  // Aplicar com segurança (evita modificar provider durante build)
  if (c.mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editorProvider.notifier).setBg(chosen);
    });
  }
}

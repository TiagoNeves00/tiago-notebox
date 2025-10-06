import 'dart:ui';
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

const _solidColors = <int>[
  // bases escuras
  0xFF0B1220, // navy profundo
  0xFF111827, // charcoal azul
  0xFF1B263B, // slate azulado

  // neons suaves
  0xFF60A5FA, // azul elétrico soft
  0xFF22D3EE, // aqua/cyan suave
  0xFFA78BFA, // violeta neon calmo
  0xFFF472B6, // magenta/pink suave
  0xFF34D399, // mint/emerald leve
  0xFFF59E0B, // amber neon contido

  // tons de respiro
  0xFFFDA4AF, // peach rosado
  0xFFE2E8F0, // slate-200
  0xFFF8FAFC, // quase branco
];

Future<void> showNoteBgPicker(BuildContext c, WidgetRef ref) async {
  final chosen = await showModalBottomSheet<String?>(
    context: c,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: .7, minChildSize: .3, maxChildSize: .95, expand: false,
      builder: (ctx, scroll) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Stack(children: [
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12))),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1720).withOpacity(.90),
                border: Border.all(color: const Color(0xFF00F5FF).withOpacity(.55)),
                boxShadow: [BoxShadow(color: const Color(0xFFEA00FF).withOpacity(.20), blurRadius: 24)],
              ),
            ),
          ),
          DefaultTabController(
            length: 2,
            child: Column(children: [
              const TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Color(0xFFEA00FF),
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFFAEC0D1),
                tabs: [Tab(text: 'Cores'), Tab(text: 'Imagens')],
              ),
              Expanded(
                child: TabBarView(children: [
                  // CORES
                  GridView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _solidColors.length,
                    itemBuilder: (_, i) {
                      final color = Color(_solidColors[i]);
                      return InkWell(
                        onTap: () => Navigator.pop(ctx, 'solid:${color.value.toRadixString(16)}'),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 1),
                            boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 10)],
                          ),
                          child: const SizedBox.expand(),
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
                    itemCount: _bgKeys.length,
                    itemBuilder: (_, i) => InkWell(
                      onTap: () => Navigator.pop(ctx, _bgKeys[i]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(_bgKeys[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    ),
  );

  ref.read(editorProvider.notifier).setBg(chosen);
}

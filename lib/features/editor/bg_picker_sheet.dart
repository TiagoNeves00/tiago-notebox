// lib/features/editor/bg_picker_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/app/app_palette.dart';
import 'package:notebox/features/editor/editor_ctrl.dart';

class BgPickerSheet extends ConsumerWidget {
  const BgPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(editorProvider).bgKey;

    void setBg(String? key) {
      ref.read(editorProvider.notifier).setBg(key);
      Navigator.of(context).pop();
    }

    final radius = BorderRadius.circular(18);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 12 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Material(
          color: const Color(0xFF0A1119),
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Fundo da nota',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // sem fundo
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setBg(null),
                    icon: const Icon(Icons.block),
                    label: const Text('Sem fundo'),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Cores',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // grid cores
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final c in AppPalette.noteBgSolids)
                      _ColorDot(
                        color: c,
                        selected: AppPalette.solidToBgKey(c) == current,
                        onTap: () => setBg(AppPalette.solidToBgKey(c)),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  'Imagens',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // grid imagens
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AppPalette.noteBgImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (_, i) {
                    final path = AppPalette.noteBgImages[i];
                    final selected = path == current;

                    return GestureDetector(
                      onTap: () => setBg(path),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(path, fit: BoxFit.cover),
                            if (selected)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFEA00FF),
                                    width: 3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFFEA00FF) : Colors.white24,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

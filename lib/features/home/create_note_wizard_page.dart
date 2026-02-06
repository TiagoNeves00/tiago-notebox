import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/data/local/db.dart';
import 'package:notebox/data/repos/folders_repo.dart';
import 'package:notebox/data/repos/notes_repo.dart';
import 'package:notebox/features/home/widgets/neon_action_button.dart';

class CreateNoteWizardPage extends ConsumerStatefulWidget {
  const CreateNoteWizardPage({super.key});

  @override
  ConsumerState<CreateNoteWizardPage> createState() =>
      _CreateNoteWizardPageState();
}

class _CreateNoteWizardPageState extends ConsumerState<CreateNoteWizardPage> {
  static const c1 = Color(0xFFEA00FF);
  static const c2 = Color(0xFF00F5FF);

  int _step = 0;

  String _title = '';
  int? _folderId;
  String? _bgKey;

  static const bgSolidOptions = <String>[
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

  static const bgImageOptions = <String>[
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

  bool get _canNext {
    if (_step == 0) return _title.trim().isNotEmpty;
    return true;
  }

  String get _header => switch (_step) {
    0 => 'Insira o título',
    1 => 'Escolha uma pasta',
    _ => 'Escolha o fundo',
  };

  Future<void> _finish() async {
    final title = _title.trim();
    if (title.isEmpty) return;

    final id = await ref
        .read(notesRepoProvider)
        .upsert(
          id: null,
          title: title,
          body: '',
          color: null,
          folderId: _folderId,
          bgKey: _bgKey,
        );

    if (!mounted) return;
    context.go('/edit/$id');
  }

  void _next() {
    if (!_canNext) return;
    if (_step == 2) {
      _finish();
      return;
    }
    setState(() => _step++);
  }

  void _cancel() => context.pop();

  Widget _stepContent(BuildContext context) {
    switch (_step) {
      case 0:
        return _StepTitle(
          initial: _title,
          onChanged: (v) => setState(() => _title = v),
        );

      case 1:
        return _StepFolder(
          selectedId: _folderId,
          onPick: (id) => setState(() => _folderId = id),
        );

      default:
        return _StepBackground(
          selected: _bgKey,
          solidOptions: bgSolidOptions,
          imageOptions: bgImageOptions,
          onPick: (k) => setState(() => _bgKey = k),
        );
    }
  }

  /// Alturas diferentes por step (resolve o teu problema)
  double _cardMaxHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    // valores práticos; ajusta se quiseres
    if (_step == 0) return h * 0.24; // título: pouco conteúdo
    if (_step == 1) return h * 0.66; // lista pastas: mais altura
    return h * 0.70; // fundos: grid precisa de altura
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Color(0xFF0A0F1A))),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
  child: Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Criar Nova Nota',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 70),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: _cardMaxHeight(context),
            ),
            child: _WizardCard(
              header: _header,
              body: _stepContent(context),
              footer: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeonActionButton(
                      icon: _step == 2 ? Icons.check : Icons.arrow_forward,
                      label: _step == 2 ? 'Criar' : 'Seguinte',
                      enabled: _canNext,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          _Dots(current: _step, total: 3),
        ],
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}

class _WizardCard extends StatelessWidget {
  const _WizardCard({
    required this.header,
    required this.body,
    required this.footer,
  });

  final String header;
  final Widget body;
  final Widget footer;

  static const c1 = Color(0xFFEA00FF);
  static const c2 = Color(0xFF00F5FF);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1720).withOpacity(.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c2.withOpacity(.55)),
              boxShadow: [
                BoxShadow(color: c1.withOpacity(.20), blurRadius: 24),
              ],
            ),
            child: Column(
              children: [
                Text(
                  header,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Corpo ocupa o que precisar; se exceder, faz scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: body,
                  ),
                ),

                const SizedBox(height: 10),
                footer,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;

  static const c1 = Color(0xFFEA00FF);
  static const c2 = Color(0xFF00F5FF);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: TextFormField(
        initialValue: initial,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          labelText: 'Título da Nota',
          labelStyle: const TextStyle(color: Color(0xFFAED2FF)),
          filled: true,
          fillColor: const Color(0xFF0A1119),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: c2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: c1, width: 1.6),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _StepFolder extends ConsumerWidget {
  const _StepFolder({required this.selectedId, required this.onPick});
  final int? selectedId;
  final void Function(int? id) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders$ = ref.watch(foldersRepoProvider).watchAll();

    return StreamBuilder<List<Folder>>(
      stream: folders$,
      builder: (_, snap) {
        final folders = snap.data ?? const <Folder>[];

        return Column(
          children: [
            RadioListTile<int?>(
              dense: true,
              value: null,
              groupValue: selectedId,
              onChanged: (v) => onPick(v),
              title: const Text(
                'Sem pasta',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Divider(height: 10),
            ...folders.map(
              (f) => RadioListTile<int?>(
                dense: true,
                value: f.id,
                groupValue: selectedId,
                onChanged: (v) => onPick(v),
                title: Text(
                  f.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StepBackground extends StatelessWidget {
  const _StepBackground({
    required this.selected,
    required this.solidOptions,
    required this.imageOptions,
    required this.onPick,
  });

  final String? selected;
  final List<String> solidOptions;
  final List<String> imageOptions;
  final void Function(String? k) onPick;

  static const neon = Color(0xFFEA00FF);

  Color _solidToColor(String k) {
    final hex = k.substring('solid:'.length);
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            t,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    Widget colorDot({required String? keyValue, required Color color}) {
      final isSel = selected == keyValue;

      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onPick(keyValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isSel
                ? [BoxShadow(color: neon.withOpacity(.45), blurRadius: 16)]
                : const [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: isSel ? neon : outline.withOpacity(.55),
                    width: isSel ? 2.0 : 1.2,
                  ),
                ),
              ),
              if (isSel)
                const Icon(Icons.check, color: Colors.white, size: 18),
            ],
          ),
        ),
      );
    }

    Widget defaultChip() {
      final isSel = selected == null;

      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onPick(null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1119),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? neon : outline.withOpacity(.55),
              width: isSel ? 2.0 : 1.2,
            ),
            boxShadow: isSel
                ? [BoxShadow(color: neon.withOpacity(.35), blurRadius: 16)]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSel ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: isSel ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 8),
              const Text(
                'Default',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget imageTile(String path) {
      final isSel = selected == path;

      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onPick(path),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(path, fit: BoxFit.cover),
              ),
            ),
            if (isSel)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: neon, width: 2),
                  ),
                  child: const Center(child: Icon(Icons.check, color: Colors.white)),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Cores'),

        // Default + grelha de bolinhas
        Row(
          children: [
            defaultChip(),
          ],
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: solidOptions.length,
          itemBuilder: (_, i) {
            final k = solidOptions[i];
            return Center(child: colorDot(keyValue: k, color: _solidToColor(k)));
          },
        ),

        const SizedBox(height: 16),
        _sectionTitle('Imagens'),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: imageOptions.length,
          itemBuilder: (_, i) => imageTile(imageOptions[i]),
        ),
      ],
    );
  }
}



class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    const active = Color(0xFFEA00FF);
    final inactive = Colors.white.withOpacity(.25);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isOn = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isOn ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOn ? active : inactive,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

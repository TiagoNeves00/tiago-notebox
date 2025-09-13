

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/theme/theme_mode.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  bool _isHome(String loc) => loc.startsWith('/notes') || loc.startsWith('/tasks');

  String _titleFor(String loc) {
    if (loc.startsWith('/folders')) return 'Pastas';
    if (loc.startsWith('/settings')) return 'Settings';
    if (loc.startsWith('/edit')) return 'Nota';
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pega no path atual através do GoRouterState
    final loc = GoRouterState.of(context).uri.toString();

    final isHome = _isHome(loc);
    final isNotes = loc.startsWith('/notes');

    return Scaffold(
      appBar: AppBar(
        leading: isHome
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/notes');
                  }
                },
              ),
        titleSpacing: 0,
        title: isHome
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'notes', label: Text('Notes')),
                    ButtonSegment(value: 'tasks', label: Text('Tasks')),
                  ],
                  selected: {isNotes ? 'notes' : 'tasks'},
                  onSelectionChanged: (s) {
                    final v = s.first;
                    if (v == 'notes') {
                      context.go('/notes');
                    } else {
                      context.go('/tasks');
                    }
                  },
                ),
              )
            : Text(_titleFor(loc)),
        actions: isHome
            ? [
                IconButton(
                  tooltip: 'Tema',
                  icon: const Icon(Icons.brightness_6),
                  onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                ),
                IconButton(
                  tooltip: 'Pastas',
                  icon: const Icon(Icons.folder_open),
                  onPressed: () => context.push('/folders'),
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.push('/settings'),
                ),
              ]
            : null,
      ),
      body: child,
    );
  }
}
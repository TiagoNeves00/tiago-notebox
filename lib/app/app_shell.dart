import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/app/notes_tasks_tabs.dart';
import 'package:notebox/features/home/home_page.dart';
import 'package:notebox/features/tasks/tasks_page.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final PageController page;
  int index = 0;

  @override
  void initState() {
    super.initState();
    page = PageController(initialPage: 0);
  }

  void _animateTo(int i) {
    setState(() => index = i);
    page.animateToPage(
      i,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: NotesTasksTabs(
          currentIndex: index,
          onSelect: _animateTo,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: () => context.push('/folders'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),

      body: PageView(
        controller: page,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => index = i),
        children: const [
          HomePage(),
          TasksPage(),
        ],
      ),
    );
  }
}

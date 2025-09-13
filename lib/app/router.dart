import 'package:go_router/go_router.dart';
import 'package:notebox/app/shell.dart';
import 'package:notebox/features/editor/note_editor_page.dart';
import 'package:notebox/features/folders/folders_page.dart';
import 'package:notebox/features/home/home_page.dart';
import 'package:notebox/features/settings/settings_page.dart';
import 'package:notebox/features/tasks/tasks_page.dart';

final appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/notes'),
        GoRoute(path: '/notes', builder: (_, __) => const HomePage()),
        GoRoute(path: '/tasks', builder: (_, __) => const TasksPage()),
        GoRoute(path: '/folders', builder: (_, __) => const FoldersPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        GoRoute(path: '/edit', builder: (_, __) => const NoteEditorPage()),
        GoRoute(
          path: '/edit/:id',
          builder: (c, s) =>
              NoteEditorPage(noteId: int.parse(s.pathParameters['id']!)),
        ),
      ],
    ),
  ],
);

// lib/app/router/router.dart
import 'package:go_router/go_router.dart';

import 'package:notebox/app/app_shell.dart';
import 'package:notebox/features/home/home_page.dart';
import 'package:notebox/features/tasks/tasks_page.dart';
import 'package:notebox/features/folders/folders_page.dart';
import 'package:notebox/features/settings/settings_page.dart';
import 'package:notebox/features/editor/note_editor_page.dart';

final appRouter = GoRouter(
  initialLocation: '/notes',
  routes: [
    // Shell com tabs só para Notes/Tasks
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/notes',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksPage(),
        ),
      ],
    ),

    // Folders fora do shell
    GoRoute(
      path: '/folders',
      builder: (context, state) => const FoldersPage(),
    ),

    // Settings fora do shell
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),

    // Editor (nova nota)
    GoRoute(
      path: '/edit',
      builder: (context, state) => const NoteEditorPage(),
    ),

    // Editor (nota existente)
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final noteId = int.tryParse(idStr);
        return NoteEditorPage(noteId: noteId);
      },
    ),
  ],
);

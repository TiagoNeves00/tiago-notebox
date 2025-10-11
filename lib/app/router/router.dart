// lib/router/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notebox/app/router/transitions.dart';
import 'package:notebox/app/shell.dart';
import 'package:notebox/features/editor/note_editor_page.dart';
import 'package:notebox/features/folders/folders_page.dart';
import 'package:notebox/features/home/home_page.dart';
import 'package:notebox/features/settings/settings_page.dart';


final appRouter = GoRouter(
  initialLocation: '/notes',
  routes: [
    ShellRoute(
      builder: (ctx, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/notes',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const HomePage(),
            transitionsBuilder: Transitions.sharedAxisX,
          ),
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const HomePage(),
            transitionsBuilder: Transitions.sharedAxisX,
          ),
        ),
        GoRoute(
          path: '/folders',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const FoldersPage(),
            transitionsBuilder: Transitions.sharedAxisY,
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const SettingsPage(),
            transitionsBuilder: Transitions.fadeThrough,
          ),
        ),
        GoRoute(
          path: '/edit',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const NoteEditorPage(), // nova nota
            transitionsBuilder: Transitions.sharedAxisZ,
          ),
        ),
        GoRoute(
          path: '/edit/:id',
          pageBuilder: (ctx, s) {
            final idStr = s.pathParameters['id']!;
            final noteId = int.tryParse(idStr);
            return CustomTransitionPage(
              key: s.pageKey,
              child: NoteEditorPage(noteId: noteId),
              transitionsBuilder: Transitions.sharedAxisZ,
            );
          },
        ),
      ],
    ),
  ],
  errorPageBuilder: (ctx, s) => CustomTransitionPage<void>(
    key: s.pageKey,
    child: Scaffold(body: Center(child: Text('Rota inválida: ${s.uri}'))),
    transitionsBuilder: Transitions.fadeThrough,
  ),
);

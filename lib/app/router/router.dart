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
            transitionsBuilder: Transitions.fadeOnly,
          ),
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const HomePage(),
            transitionsBuilder: Transitions.fadeOnly,
          ),
        ),
        GoRoute(
          path: '/folders',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const FoldersPage(),
            transitionsBuilder: Transitions.fadeOnly,
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const SettingsPage(),
            transitionsBuilder: Transitions.fadeOnly,
          ),
        ),

        // NOVA NOTA
        GoRoute(
          path: '/edit',
          pageBuilder: (ctx, s) => CustomTransitionPage(
            key: s.pageKey,
            child: const NoteEditorPage(),
            transitionsBuilder: Transitions.fadeOnly,
            transitionDuration: const Duration(milliseconds: 350),
          ),
        ),

        // EDITAR NOTA EXISTENTE
        GoRoute(
          path: '/edit/:id',
          pageBuilder: (ctx, s) {
            final idStr = s.pathParameters['id']!;
            final noteId = int.tryParse(idStr);

            return CustomTransitionPage(
              key: s.pageKey,
              child: NoteEditorPage(noteId: noteId),
              transitionsBuilder: Transitions.fadeOnly,
              transitionDuration: const Duration(milliseconds: 350),
              reverseTransitionDuration: const Duration(milliseconds: 300),
            );
          },
        ),
      ],
    ),
  ],

  errorPageBuilder: (ctx, s) => CustomTransitionPage<void>(
    key: s.pageKey,
    child: Scaffold(body: Center(child: Text('Rota inválida: ${s.uri}'))),
    transitionsBuilder: Transitions.fadeOnly,
  ),
);

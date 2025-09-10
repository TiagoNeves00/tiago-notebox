import 'package:go_router/go_router.dart';
import 'package:notebox/features/editor/note_editor_page.dart';
import 'package:notebox/features/home/home_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/edit', builder: (_, __) => const NoteEditorPage()),
    GoRoute(path: '/edit/:id', builder: (c, s) =>
      NoteEditorPage(noteId: int.parse(s.pathParameters['id']!))),
  ],
);
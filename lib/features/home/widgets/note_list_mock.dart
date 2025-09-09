import 'package:flutter/material.dart';

final _notes = List.generate(
  8,
  (i) => {'title': 'Nota $i', 'body': 'Pré-visualização... $i'},
);

class NoteListMock extends StatelessWidget {
  final bool grid;
  const NoteListMock({super.key, required this.grid});

  @override
  Widget build(BuildContext context) {
    if (grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _notes.length,
        itemBuilder: (_, i) => _NoteCard(note: _notes[i]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _notes.length,
      itemBuilder: (_, i) => _NoteCard(note: _notes[i]),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Map<String, String> note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note['title']!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(note['body']!, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

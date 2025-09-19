import 'package:flutter/material.dart';

Future<void> showQuickNote(BuildContext c, {required Future<void> Function(String) onSave}) async {
  final tc = TextEditingController();
  await showModalBottomSheet<void>(
    context: c, isScrollControlled: true, showDragHandle: true,
    builder: (_) {
      final pad = MediaQuery.of(c).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, pad + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: tc, autofocus: true, decoration: const InputDecoration(hintText: 'Nota rápida…')),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async { final t = tc.text.trim(); if (t.isNotEmpty) await onSave(t); if (c.mounted) Navigator.pop(c); },
            icon: const Icon(Icons.check), label: const Text('Criar'),
          ),
        ]),
      );
    },
  );
}
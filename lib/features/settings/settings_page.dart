import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.palette),
          title: Text('Tema'),
          subtitle: Text('Claro/Escuro segue no topo'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Sobre'),
          subtitle: Text('NoteBox • MVP'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist_rounded, size: 52, color: Colors.white54),
          SizedBox(height: 16),
          Text("Coming soon",
              style: TextStyle(fontSize: 24, color: Colors.white)),
          SizedBox(height: 6),
          Text(
            "A área de tarefas ainda está em construção.",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

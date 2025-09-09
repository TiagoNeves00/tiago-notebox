import 'package:flutter/material.dart';

class FolderMock {
  final String name;
  final int count;
  final Color color;
  const FolderMock(this.name, this.count, this.color);
}

const foldersMock = <FolderMock>[
  FolderMock('All', 42, Color(0xFFB3E5FC)),
  FolderMock('Work', 12, Color(0xFFFFF59D)),
  FolderMock('Personal', 9, Color(0xFFC8E6C9)),
  FolderMock('Study', 21, Color(0xFFD1C4E9)),
];
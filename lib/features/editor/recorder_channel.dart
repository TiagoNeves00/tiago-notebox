import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AndroidRecorder {
  AndroidRecorder._();
  static final AndroidRecorder instance = AndroidRecorder._();
  static const _ch = MethodChannel('notebox/recorder');
  final _uuid = const Uuid();

  Future<String> _newPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final recDir = Directory('${dir.path}/voice');
    if (!await recDir.exists()) await recDir.create(recursive: true);
    final id = _uuid.v4();
    return '${recDir.path}/$id.m4a';
    // guarda este path na nota; é interno e persiste
  }

  Future<String?> start() async {
    final path = await _newPath();
    final ok = await _ch.invokeMethod<bool>('start', {'path': path}) ?? false;
    if (!ok) return null;
    return path; // devolvo já o path planeado (útil para UI)
  }

  Future<String?> stop() async {
    final out = await _ch.invokeMethod<String>('stop');
    return out; // path definitivo (igual ao planeado)
  }

  Future<bool> isRecording() async {
    return await _ch.invokeMethod<bool>('isRecording') ?? false;
  }
}

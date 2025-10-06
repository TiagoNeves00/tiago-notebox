import 'package:flutter/material.dart';

bool isSolidBg(String? key) => key?.startsWith('solid:') == true;

Color? parseSolidBg(String? key) {
  if (!isSolidBg(key)) return null;
  // "solid:ff0e1720" -> 0xFF0E1720
  final hex = key!.substring(6);
  final v = int.parse(hex, radix: 16);
  return Color(v);
}
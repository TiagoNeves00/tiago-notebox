import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notebox/features/home/widgets/neon_action_button.dart';

Future<String?> confirmRenameFolder(
  BuildContext context, {
  String initial = '',
}) async {
  const c1 = Color(0xFFEA00FF), c2 = Color(0xFF00F5FF);

  String value = initial;

  return (await showDialog<String>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: const Color.fromARGB(0, 58, 0, 0),
      insetPadding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12)),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1720).withOpacity(.88),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c2.withOpacity(.55)),
                boxShadow: [BoxShadow(color: c1.withOpacity(.20), blurRadius: 24)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Renomear pasta',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: initial,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nome da pasta',
                      labelStyle: const TextStyle(color: Color(0xFFAED2FF)),
                      filled: true,
                      fillColor: const Color(0xFF0A1119),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: c2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: c1, width: 1.6),
                      ),
                    ),
                    onChanged: (s) => value = s,
                    onFieldSubmitted: (_) {
                      final name = value.trim();
                      if (name.isEmpty) return;
                      Navigator.of(context, rootNavigator: true).pop(name);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeonActionButton(
                          icon: Icons.save,
                          label: 'Guardar',
                          enabled: value.trim().isNotEmpty,
                          onPressed: () {
                            final name = value.trim();
                            if (name.isEmpty) return;
                            Navigator.of(context, rootNavigator: true).pop(name);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ));
}

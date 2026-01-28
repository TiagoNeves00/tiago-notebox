import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notebox/features/home/widgets/neon_action_button.dart';

Future<String?> confirmNewFolder(BuildContext context) async {
  const c1 = Color(0xFFEA00FF), c2 = Color(0xFF00F5FF);

  return await showDialog<String>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (_) {
      String value = '';
      return StatefulBuilder(
        builder: (ctx, setState) => Dialog(
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
                        'Nova pasta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
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
                        onChanged: (s) => setState(() => value = s),
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
                              onPressed: () =>
                                  Navigator.of(context, rootNavigator: true).pop(null),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: NeonActionButton(
                              icon: Icons.add,
                              label: 'Criar',
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
      );
    },
  );
}

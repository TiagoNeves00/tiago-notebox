import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notebox/features/home/widgets/neon_action_button.dart';

Future<bool> confirmDeleteFolder(
  BuildContext context, {
  required String folderName,
}) async {
  const c1 = Color(0xFFEA00FF), c2 = Color(0xFF00F5FF);

  return (await showDialog<bool>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.35),
        builder: (_) => Stack(
          children: [
            // Blur do background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Dialog
            Center(
              child: Dialog(
                backgroundColor: const Color.fromARGB(0, 58, 0, 0),
                insetPadding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
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
                        Text(
                          'Eliminar "$folderName"?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'As notas dentro da pasta NÃO serão apagadas. Ficarão associadas a "Sem pasta".',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFAED2FF)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true).pop(false),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: NeonActionButton(
                                icon: Icons.delete,
                                label: 'Eliminar',
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true).pop(true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )) ??
      false;
}

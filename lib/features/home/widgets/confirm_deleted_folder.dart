import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notebox/features/home/widgets/neon_action_button.dart';

Future<bool> confirmDeleteFolder(BuildContext context) async {
  const c1 = Color(0xFFEA00FF), c2 = Color(0xFF00F5FF);
  return (await showDialog<bool>(
    context: context, useRootNavigator: true, barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1720).withOpacity(.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c2.withOpacity(.55)),
              boxShadow: [BoxShadow(color: c1.withOpacity(.20), blurRadius: 24)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Eliminar pasta?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('As notas NÃO são apagadas. Vão para "Sem pasta".', style: TextStyle(color: Color(0xFFAED2FF))),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                  child: const Text('Cancelar'),
                )),
                const SizedBox(width: 12),
                Expanded(child: NeonActionButton(
                  icon: Icons.delete, label: 'Eliminar',
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                )),
              ]),
            ]),
          ),
        ]),
      ),
    ),
  )) ?? false;
}

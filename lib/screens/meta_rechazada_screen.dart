import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/app_button.dart';
import 'chat_ia_screen.dart';

/// Se muestra cuando GET /api/solicitudes-ia/{id} devuelve
/// estado = "rechazada" (ver MetaSeguridadHandler.hpp en el backend:
/// las reglas de seguridad -RF-09/RNF-07- rechazaron la meta antes de
/// generar cualquier rutina).
class MetaRechazadaScreen extends StatelessWidget {
  const MetaRechazadaScreen({super.key, required this.motivo, required this.usuarioId});
  final String motivo;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear rutina con IA')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.amber, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Esta meta no es segura',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                motivo.isNotEmpty
                    ? motivo
                    : 'La meta que describiste no cumple con un ritmo de cambio saludable.',
                style: const TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 28),
              const Text(
                'Si tienes dudas sobre tu salud, consulta a un profesional antes de empezar.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const Spacer(),
              AppButton(
                texto: 'Intentar con otra meta',
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ChatIAScreen(usuarioId: usuarioId)),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                texto: 'Volver al inicio',
                kind: AppButtonKind.secundario,
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Muestra el mensaje de un ApiException (u otro error) de forma
/// consistente en toda la app, distinguiendo visualmente un problema de
/// red (para el que sí tiene sentido sugerir "reintentar") de un error
/// de negocio devuelto por el backend.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.mensaje, this.onReintentar});

  final String mensaje;
  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.1),
        border: Border.all(color: AppColors.red),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(mensaje, style: const TextStyle(color: AppColors.text, fontSize: 13)),
          ),
          if (onReintentar != null)
            TextButton(
              onPressed: onReintentar,
              child: const Text('Reintentar', style: TextStyle(color: AppColors.red)),
            ),
        ],
      ),
    );
  }
}

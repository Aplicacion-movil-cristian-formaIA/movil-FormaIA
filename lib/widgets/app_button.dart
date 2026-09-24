import 'package:flutter/material.dart';

enum AppButtonKind { primario, secundario }

/// Botón con estado de carga incorporado (evita repetir el patrón
/// "deshabilitar mientras isLoading" en cada pantalla que llama al
/// backend).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.kind = AppButtonKind.primario,
    this.cargando = false,
    this.icono,
  });

  final String texto;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final bool cargando;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final deshabilitado = cargando || onPressed == null;
    final child = cargando
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icono != null) ...[Icon(icono, size: 20), const SizedBox(width: 8)],
              Text(texto),
            ],
          );

    if (kind == AppButtonKind.secundario) {
      return OutlinedButton(onPressed: deshabilitado ? null : onPressed, child: child);
    }
    return ElevatedButton(onPressed: deshabilitado ? null : onPressed, child: child);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/app_theme.dart';
import '../core/session.dart';
import '../models/solicitud_ia.dart';
import '../services/rutina_service.dart';
import '../services/solicitud_service.dart';
import '../widgets/app_button.dart';
import '../widgets/error_banner.dart';
import 'meta_rechazada_screen.dart';
import 'plan_screen.dart';

enum _Fase { escribiendo, procesando, error }

class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key, required this.usuarioId});
  final String usuarioId;

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final _textoCtrl = TextEditingController();
  _Fase _fase = _Fase.escribiendo;
  String _estadoTexto = '';
  String? _error;

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _textoCtrl.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _fase = _Fase.procesando;
      _error = null;
      _estadoTexto = 'Enviando tu meta...';
    });

    final solicitudService = context.read<SolicitudService>();
    final rutinaService = context.read<RutinaService>();

    try {
      final solicitudId = await solicitudService.crear(
        usuarioId: widget.usuarioId,
        texto: texto,
      );
      await Session.instance.guardarSolicitudId(solicitudId);

      // El backend procesa esto de forma asíncrona (ver el comentario en
      // SolicitudController.hpp): interpretar la meta con Groq, validar
      // reglas de seguridad, armar la progresión y guardarla. Aquí solo
      // vamos preguntando el estado hasta que termine.
      SolicitudIA? ultimaSolicitud;
      await for (final s in solicitudService.esperarResultado(solicitudId)) {
        ultimaSolicitud = s;
        if (!mounted) return;
        setState(() {
          _estadoTexto = s.referenteDetectado.isNotEmpty
              ? 'Analizando a ${s.referenteDetectado} y armando tu plan...'
              : 'Armando tu plan progresivo...';
        });
      }

      if (!mounted || ultimaSolicitud == null) return;

      if (ultimaSolicitud.estado == EstadoSolicitud.rechazada) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MetaRechazadaScreen(
              motivo: ultimaSolicitud!.motivoRechazo,
              usuarioId: widget.usuarioId,
            ),
          ),
        );
        return;
      }

      if (ultimaSolicitud.estado == EstadoSolicitud.error) {
        setState(() {
          _fase = _Fase.error;
          _error = 'Algo falló generando tu rutina. Intenta de nuevo.';
        });
        return;
      }

      // estado == generada
      final rutina = await rutinaService.obtenerPorSolicitud(solicitudId);
      await Session.instance.guardarRutinaId(rutina.id);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PlanScreen(rutinaId: rutina.id)),
      );
    } on ApiException catch (e) {
      setState(() {
        _fase = _Fase.error;
        _error = e.mensaje;
      });
    }
  }

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
              const Text(
                'Cuéntame qué quieres lograr, con tus propias palabras.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ej: "quiero bajar de peso y verme como Kirito, tengo 4 días a la semana"',
                style: TextStyle(color: AppColors.muted, fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textoCtrl,
                maxLines: 4,
                enabled: _fase == _Fase.escribiendo || _fase == _Fase.error,
                decoration: const InputDecoration(hintText: 'Escribe tu meta...'),
              ),
              const SizedBox(height: 20),
              if (_fase == _Fase.procesando) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_estadoTexto, style: const TextStyle(color: AppColors.muted))),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              if (_error != null) ...[
                ErrorBanner(mensaje: _error!),
                const SizedBox(height: 16),
              ],
              AppButton(
                texto: 'Crear rutina',
                cargando: _fase == _Fase.procesando,
                onPressed: _fase == _Fase.procesando ? null : _enviar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

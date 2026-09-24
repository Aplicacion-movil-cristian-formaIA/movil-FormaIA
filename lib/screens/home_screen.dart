import 'package:flutter/material.dart';

import '../core/session.dart';
import '../widgets/app_button.dart';
import 'chat_ia_screen.dart';
import 'plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.usuarioId});
  final String usuarioId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _rutinaId;
  bool _cargandoSesion = true;

  @override
  void initState() {
    super.initState();
    _cargarUltimaRutina();
  }

  Future<void> _cargarUltimaRutina() async {
    final id = await Session.instance.obtenerRutinaId();
    if (!mounted) return;
    setState(() {
      _rutinaId = id;
      _cargandoSesion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hola 👋', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('¿Qué quieres lograr hoy?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              if (!_cargandoSesion && _rutinaId != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tienes un plan activo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Retómalo para ver tus fases y tu progresión.'),
                        const SizedBox(height: 16),
                        AppButton(
                          texto: 'Ver mi plan',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => PlanScreen(rutinaId: _rutinaId!)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              AppButton(
                texto: 'Crear rutina con IA',
                icono: Icons.auto_awesome,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ChatIAScreen(usuarioId: widget.usuarioId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/rutina_service.dart';

import '../core/session.dart';
import '../widgets/app_button.dart';
import '../core/app_theme.dart';
import 'chat_ia_screen.dart';
import 'plan_screen.dart';
import 'profile_form_screen.dart';
import 'reporte_evolucion_screen.dart';

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
    setState(() => _cargandoSesion = true);
    try {
      final service = context.read<RutinaService>();
      final id = await service.obtenerRutinaActiva(widget.usuarioId);
      if (id != null) {
        await Session.instance.guardarRutinaId(id);
      }
      if (!mounted) return;
      setState(() {
        _rutinaId = id;
        _cargandoSesion = false;
      });
    } catch (_) {
      final id = await Session.instance.obtenerRutinaId();
      if (!mounted) return;
      setState(() {
        _rutinaId = id;
        _cargandoSesion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola 👋', style: TextStyle(color: AppColors.mint, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Tu panel de control',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileFormScreen(usuarioId: widget.usuarioId, esEdicion: true),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: AppColors.surface2,
                      child: Icon(Icons.person, color: AppColors.mint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              if (_cargandoSesion)
                const Center(child: CircularProgressIndicator())
              else if (_rutinaId != null)
                _buildActiveRoutineCard(context)
              else
                _buildCreateRoutineCard(context),

              const SizedBox(height: 32),
              const Text('Accesos rápidos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccess(
                      icon: Icons.av_timer,
                      color: AppColors.primary,
                      title: 'Simular\nSemana',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ReporteEvolucionScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAccess(
                      icon: Icons.settings,
                      color: AppColors.coral,
                      title: 'Ajustar\nPerfil',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProfileFormScreen(usuarioId: widget.usuarioId, esEdicion: true),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRoutineCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surface2, AppColors.surface1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Plan Activo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Continúa tu progreso hacia tu meta.', style: TextStyle(color: AppColors.muted, fontSize: 15)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text('VER MI PLAN', style: TextStyle(fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PlanScreen(rutinaId: _rutinaId!)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRoutineCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.mint, size: 40),
          const SizedBox(height: 16),
          const Text('Sin plan activo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Genera tu primera rutina usando inteligencia artificial adaptada a tus objetivos.',
              style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.4)),
          const SizedBox(height: 24),
          AppButton(
            texto: 'Crear mi rutina',
            icono: Icons.add,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChatIAScreen(usuarioId: widget.usuarioId)),
              );
              _cargarUltimaRutina();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess({required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/app_theme.dart';
import '../models/rutina.dart';
import '../services/rutina_service.dart';
import '../widgets/error_banner.dart';
import 'modo_entrenamiento_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key, required this.rutinaId});
  final String rutinaId;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late Future<Rutina> _futuro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _futuro = context.read<RutinaService>().obtener(widget.rutinaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu plan')),
      body: SafeArea(
        child: FutureBuilder<Rutina>(
          future: _futuro,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final mensaje = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).mensaje
                  : 'No se pudo cargar tu plan.';
              return Padding(
                padding: const EdgeInsets.all(24),
                child: ErrorBanner(
                  mensaje: mensaje,
                  onReintentar: () => setState(_cargar),
                ),
              );
            }

            final rutina = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(rutina.nombre, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${rutina.semanasTotales} semanas · progresivo',
                    style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 24),
                for (final fase in rutina.fases) _FaseCard(fase: fase),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ModoEntrenamientoScreen()));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('¡COMENZAR ENTRENAMIENTO!', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FaseCard extends StatelessWidget {
  const _FaseCard({required this.fase});
  final Fase fase;

  static const _colores = [AppColors.mint, AppColors.primary, AppColors.coral];

  @override
  Widget build(BuildContext context) {
    final color = _colores[(fase.orden - 1) % _colores.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${fase.orden}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fase.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  'Semanas ${fase.semanaInicio}–${fase.semanaFin} · ${fase.duracionSemanas} sem.',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                if (fase.objetivo.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(fase.objetivo, style: const TextStyle(fontSize: 13, height: 1.3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

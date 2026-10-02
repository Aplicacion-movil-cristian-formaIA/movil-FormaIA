import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/session.dart';
import '../services/entrenamiento_service.dart';

class ReporteEvolucionScreen extends StatefulWidget {
  const ReporteEvolucionScreen({super.key});

  @override
  State<ReporteEvolucionScreen> createState() => _ReporteEvolucionScreenState();
}

class _ReporteEvolucionScreenState extends State<ReporteEvolucionScreen> {
  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _reporte;

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  Future<void> _cargarReporte() async {
    try {
      final service = context.read<EntrenamientoService>();
      final uid = await Session.instance.obtenerUsuarioId() ?? 'test_user';
      final reporte = await service.evaluarSemana(uid);
      if (mounted) {
        setState(() {
          _reporte = reporte;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Resumen Semanal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _cargando
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.mint),
                  SizedBox(height: 24),
                  Text('La IA está analizando tu rendimiento...',
                      style: TextStyle(color: AppColors.muted)),
                ],
              ),
            )
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.coral)))
              : _buildReporte(),
    );
  }

  Widget _buildReporte() {
    final mensaje = _reporte?['mensaje_motivacional'] ?? '';
    final ajustes = _reporte?['ajustes'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 64),
          const SizedBox(height: 24),
          Text(
            '¡Semana Completada!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              mensaje,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Ajustes de Sobrecarga para la próxima semana:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.mint),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: ajustes.length,
              itemBuilder: (context, index) {
                final ajuste = ajustes[index];
                return Card(
                  color: AppColors.surface2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.fitness_center, color: Colors.white, size: 20),
                    ),
                    title: Text(ajuste['ejercicio'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(ajuste['razon'], style: const TextStyle(color: AppColors.muted)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ajuste['incremento'],
                        style: const TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('ENTENDIDO', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

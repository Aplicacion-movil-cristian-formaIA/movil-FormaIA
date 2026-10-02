import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/session.dart';
import '../services/entrenamiento_service.dart';

class ModoEntrenamientoScreen extends StatefulWidget {
  const ModoEntrenamientoScreen({super.key});

  @override
  State<ModoEntrenamientoScreen> createState() => _ModoEntrenamientoScreenState();
}

class _ModoEntrenamientoScreenState extends State<ModoEntrenamientoScreen> {
  final List<Map<String, dynamic>> _ejercicios = [
    {"nombre": "Press de Banca", "series": 4, "reps": "8-12", "completado": false},
    {"nombre": "Sentadilla libre", "series": 4, "reps": "8-10", "completado": false},
    {"nombre": "Remo con barra", "series": 3, "reps": "10-12", "completado": false},
  ];

  final Map<String, TextEditingController> _pesoControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};

  @override
  void initState() {
    super.initState();
    for (var ej in _ejercicios) {
      _pesoControllers[ej['nombre']] = TextEditingController(text: "0");
      _repsControllers[ej['nombre']] = TextEditingController(text: "0");
    }
  }

  @override
  void dispose() {
    _pesoControllers.values.forEach((c) => c.dispose());
    _repsControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Entrenamiento'),
        backgroundColor: AppColors.surface1,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high, color: AppColors.primary),
            tooltip: 'Adaptar sesión de hoy',
            onPressed: () => _mostrarModalAdaptacion(context),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              color: AppColors.surface1,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fase 1: Adaptación', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Día 1 - Full Body', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('60 min aprox', style: TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _ejercicios.length,
                itemBuilder: (context, index) {
                  final ej = _ejercicios[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ej['completado'] ? AppColors.surface1 : AppColors.surface2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ej['nombre'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            IconButton(
                              icon: const Icon(Icons.swap_horiz, color: AppColors.muted),
                              onPressed: () {
                                _mostrarSustitutos(context, ej['nombre'], index);
                              },
                              tooltip: 'Cambiar Ejercicio',
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${ej['series']} series x ${ej['reps']} reps', style: const TextStyle(color: AppColors.primary)),
                        const SizedBox(height: 16),
                        if (!ej['completado'])
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _pesoControllers[ej['nombre']],
                                  decoration: InputDecoration(
                                    labelText: 'Peso (kg)',
                                    filled: true,
                                    fillColor: AppColors.bg,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _repsControllers[ej['nombre']],
                                  decoration: InputDecoration(
                                    labelText: 'Reps reales',
                                    filled: true,
                                    fillColor: AppColors.bg,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ej['completado'] ? AppColors.surface1 : AppColors.primary,
                              foregroundColor: ej['completado'] ? AppColors.primary : AppColors.bg,
                              elevation: 0,
                            ),
                            onPressed: () {
                              setState(() {
                                ej['completado'] = !ej['completado'];
                              });
                            },
                            child: Text(ej['completado'] ? 'Desmarcar' : 'Marcar como Completado'),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    List<Map<String, dynamic>> seriesReales = [];
                    for (var ej in _ejercicios) {
                      double peso = double.tryParse(_pesoControllers[ej['nombre']]?.text ?? '0') ?? 0.0;
                      int reps = int.tryParse(_repsControllers[ej['nombre']]?.text ?? '0') ?? 0;
                      
                      for (int i=1; i<=ej['series']; i++) {
                         seriesReales.add({
                           'ejercicio_id': ej['nombre'],
                           'numero_serie': i,
                           'reps': reps > 0 ? reps : 10,
                           'peso': peso > 0 ? peso : 50.0
                         });
                      }
                    }
                    _mostrarFeedbackRPE(context, seriesReales);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('FINALIZAR ENTRENAMIENTO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _mostrarFeedbackRPE(BuildContext context, List<Map<String, dynamic>> seriesReales) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: _ModalFeedbackRPE(
            sesionId: widget.sesionId,
            seriesReales: seriesReales,
          ),
        );
      },
    );
  }

  void _mostrarModalAdaptacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: _ModalAdaptacion(
            ejerciciosActuales: _ejercicios,
            onAdaptado: (nuevos) {
              setState(() {
                _ejercicios.clear();
                _ejercicios.addAll(nuevos.map((e) => {
                  "nombre": e['nombre'],
                  "series": e['series'] ?? 3,
                  "reps": "Según IA",
                  "completado": false,
                }));
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión adaptada por la IA a tus necesidades de hoy.')),
              );
            },
          ),
        );
      },
    );
  }

  void _mostrarSustitutos(BuildContext context, String ejercicio, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _ModalSustitucion(
          ejercicio: ejercicio,
          onReemplazar: (nuevoEjercicio) {
            setState(() {
              _ejercicios[index]['nombre'] = nuevoEjercicio;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _ModalSustitucion extends StatefulWidget {
  final String ejercicio;
  final Function(String) onReemplazar;

  const _ModalSustitucion({required this.ejercicio, required this.onReemplazar});

  @override
  State<_ModalSustitucion> createState() => _ModalSustitucionState();
}

class _ModalSustitucionState extends State<_ModalSustitucion> {
  bool _cargando = false;
  List<dynamic> _alternativas = [];
  String? _error;

  Future<void> _buscarAlternativa(String motivo) async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final service = context.read<EntrenamientoService>();
      final alts = await service.obtenerAlternativas(widget.ejercicio, motivo);
      if (mounted) {
        setState(() {
          _alternativas = alts;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al buscar alternativas: $e';
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sustituir ${widget.ejercicio}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_cargando)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (_alternativas.isNotEmpty) ...[
            const Text('Alternativas sugeridas por IA:', style: TextStyle(color: AppColors.primary)),
            const SizedBox(height: 8),
            ..._alternativas.map((alt) => ListTile(
                  title: Text(alt.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(alt.razon),
                  trailing: const Icon(Icons.check_circle, color: AppColors.mint),
                  onTap: () => widget.onReemplazar(alt.nombre),
                )),
          ] else if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.coral)),
          ] else ...[
            const Text('¿Por qué quieres cambiarlo?'),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: AppColors.primary),
              title: const Text('Máquina ocupada / Sin equipo'),
              onTap: () => _buscarAlternativa('Máquina ocupada o no tengo el equipo necesario'),
            ),
            ListTile(
              leading: const Icon(Icons.healing, color: AppColors.coral),
              title: const Text('Siento molestia o dolor'),
              onTap: () => _buscarAlternativa('Me causa dolor o molestia articular'),
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: AppColors.mint),
              title: const Text('Quiero otra variante'),
              onTap: () => _buscarAlternativa('Quiero probar una variante diferente'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModalFeedbackRPE extends StatefulWidget {
  final String sesionId;
  final List<Map<String, dynamic>> seriesReales;

  const _ModalFeedbackRPE({required this.sesionId, required this.seriesReales});

  @override
  State<_ModalFeedbackRPE> createState() => _ModalFeedbackRPEState();
}

class _ModalFeedbackRPEState extends State<_ModalFeedbackRPE> {
  double _rpeValue = 5.0;
  bool _guardando = false;

  Future<void> _finalizar() async {
    setState(() => _guardando = true);
    try {
      final service = context.read<EntrenamientoService>();
      final usuarioId = await Session.instance.obtenerUsuarioId() ?? 'test_user';

      // 1. Guardar la sesión como completada (Lógica original)
      final notificaciones = await service.registrarSesion(
        usuarioId: usuarioId,
        sesionPlanId: widget.sesionId,
        completado: true,
        series: widget.seriesReales,
      );

      // 2. Enviar RPE Feedback para Autorregulación y Sobrecarga Progresiva (Lo nuevo)
      await service.enviarFeedbackRPE(widget.sesionId, usuarioId, _rpeValue.toInt());

      if (mounted) {
        Navigator.pop(context); // Cierra modal
        Navigator.pop(context); // Cierra pantalla entrenamiento
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Entrenamiento Finalizado! La IA ajustará tu próxima sesión.')),
        );
        
        // Mostrar notificaciones de récords personales (1RM)
        for (var n in notificaciones) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🏆 $n'), backgroundColor: AppColors.primary, duration: const Duration(seconds: 4)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Qué tan difícil fue hoy?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Usaremos esto para ajustar el peso y duración de tu próxima sesión.', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Muy Fácil (1)', style: TextStyle(color: AppColors.mint)),
            Text('Imposible (10)', style: TextStyle(color: AppColors.coral)),
          ],
        ),
        Slider(
          value: _rpeValue,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: _rpeValue < 5 ? AppColors.mint : (_rpeValue > 7 ? AppColors.coral : Colors.orange),
          label: _rpeValue.round().toString(),
          onChanged: (val) => setState(() => _rpeValue = val),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _guardando ? null : _finalizar,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _guardando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                : const Text('GUARDAR Y TERMINAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ModalAdaptacion extends StatefulWidget {
  final List<Map<String, dynamic>> ejerciciosActuales;
  final Function(List<Map<String, dynamic>>) onAdaptado;

  const _ModalAdaptacion({required this.ejerciciosActuales, required this.onAdaptado});

  @override
  State<_ModalAdaptacion> createState() => _ModalAdaptacionState();
}

class _ModalAdaptacionState extends State<_ModalAdaptacion> {
  bool _cargando = false;
  final TextEditingController _motivoController = TextEditingController();

  Future<void> _adaptar() async {
    if (_motivoController.text.trim().isEmpty) return;
    setState(() => _cargando = true);
    try {
      final service = context.read<EntrenamientoService>();
      final adaptados = await service.adaptarSesionHoy(widget.ejerciciosActuales, _motivoController.text);
      if (mounted) {
        widget.onAdaptado(adaptados);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adaptar sesión de hoy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('¿Qué ocurre? (Ej: "Solo tengo 15 mins", "Me duele la rodilla", "No puedo hacer ruido")', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        TextField(
          controller: _motivoController,
          decoration: InputDecoration(
            hintText: 'Describe tu situación...',
            filled: true,
            fillColor: AppColors.surface2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _cargando ? null : _adaptar,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _cargando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                : const Text('ADAPTAR CON IA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

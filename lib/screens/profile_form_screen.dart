import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/perfil_fisico.dart';
import '../services/usuario_service.dart';
import '../widgets/app_button.dart';
import '../widgets/error_banner.dart';
import 'home_screen.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key, required this.usuarioId, this.esEdicion = false});
  final String usuarioId;
  final bool esEdicion;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _estaturaCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();

  String _sexo = 'prefiero_no_decir';
  String _nivel = 'principiante';
  int _diasSemana = 3;
  int _minutosSesion = 30;
  Set<String> _equipamiento = {'sin_equipo'};

  bool _cargando = false;
  bool _cargandoDatos = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.esEdicion) {
      _cargarPerfil();
    }
  }

  Future<void> _cargarPerfil() async {
    setState(() => _cargandoDatos = true);
    try {
      final p = await context.read<UsuarioService>().obtenerPerfil(widget.usuarioId);
      if (!mounted) return;
      setState(() {
        _estaturaCtrl.text = p.estaturaCm.toString();
        _pesoCtrl.text = p.pesoKg.toString();
        _sexo = p.sexo;
        _nivel = p.nivel;
        _diasSemana = p.diasSemana;
        _minutosSesion = p.minutosSesion;
        _equipamiento = p.equipamiento.isEmpty ? {'sin_equipo'} : p.equipamiento.toSet();
      });
    } catch (e) {
      // Ignore if not found
    } finally {
      if (mounted) setState(() => _cargandoDatos = false);
    }
  }

  @override
  void dispose() {
    _estaturaCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final perfil = PerfilFisico(
        sexo: _sexo,
        estaturaCm: double.parse(_estaturaCtrl.text),
        pesoKg: double.parse(_pesoCtrl.text),
        nivel: _nivel,
        diasSemana: _diasSemana,
        minutosSesion: _minutosSesion,
        equipamiento: _equipamiento.toList(),
      );

      await context.read<UsuarioService>().guardarPerfil(widget.usuarioId, perfil);

      if (!mounted) return;
      
      if (widget.esEdicion) {
        Navigator.of(context).pop(); // Vuelve a Perfil/Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado. La IA usará estos datos.')),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen(usuarioId: widget.usuarioId)),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoDatos) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cuéntanos sobre ti',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _estaturaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Estatura (cm)'),
                        validator: _validarNumeroPositivo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pesoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Peso (kg)'),
                        validator: _validarNumeroPositivo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Sexo', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _SegmentedChoice(
                  opciones: const {
                    'femenino': 'Femenino',
                    'masculino': 'Masculino',
                    'prefiero_no_decir': 'Prefiero no decir',
                  },
                  seleccionado: _sexo,
                  onChanged: (v) => setState(() => _sexo = v),
                ),
                const SizedBox(height: 20),
                const Text('Nivel de experiencia', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _SegmentedChoice(
                  opciones: const {
                    'principiante': 'Principiante',
                    'intermedio': 'Intermedio',
                    'avanzado': 'Avanzado',
                  },
                  seleccionado: _nivel,
                  onChanged: (v) => setState(() => _nivel = v),
                ),
                const SizedBox(height: 20),
                Text('Días disponibles por semana: $_diasSemana',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: _diasSemana.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  label: '$_diasSemana',
                  onChanged: (v) => setState(() => _diasSemana = v.round()),
                ),
                const SizedBox(height: 12),
                Text('Minutos por sesión: $_minutosSesion',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: _minutosSesion.toDouble(),
                  min: 15,
                  max: 90,
                  divisions: 15,
                  label: '$_minutosSesion',
                  onChanged: (v) => setState(() => _minutosSesion = v.round()),
                ),
                const SizedBox(height: 20),
                const Text('Equipamiento disponible', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: {
                    'sin_equipo': 'Sin equipo',
                    'mancuernas': 'Mancuernas',
                    'gimnasio': 'Gimnasio completo',
                  }.entries.map((e) {
                    final activo = _equipamiento.contains(e.key);
                    return FilterChip(
                      label: Text(e.value),
                      selected: activo,
                      onSelected: (_) => setState(() {
                        activo ? _equipamiento.remove(e.key) : _equipamiento.add(e.key);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  ErrorBanner(mensaje: _error!),
                  const SizedBox(height: 16),
                ],
                AppButton(texto: 'Crear mi perfil', cargando: _cargando, onPressed: _guardar),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validarNumeroPositivo(String? v) {
    if (v == null || v.isEmpty) return 'Requerido';
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'Ingresa un número válido';
    return null;
  }
}

class _SegmentedChoice extends StatelessWidget {
  const _SegmentedChoice({
    required this.opciones,
    required this.seleccionado,
    required this.onChanged,
  });

  final Map<String, String> opciones;
  final String seleccionado;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opciones.entries.map((e) {
        final activo = e.key == seleccionado;
        return ChoiceChip(
          label: Text(e.value),
          selected: activo,
          onSelected: (_) => onChanged(e.key),
        );
      }).toList(),
    );
  }
}

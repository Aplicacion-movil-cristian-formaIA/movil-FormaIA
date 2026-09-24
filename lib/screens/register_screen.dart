import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/session.dart';
import '../services/usuario_service.dart';
import '../widgets/app_button.dart';
import '../widgets/error_banner.dart';
import 'profile_form_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  DateTime? _fechaNacimiento;

  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: DateTime(ahora.year - 20),
      firstDate: DateTime(ahora.year - 100),
      lastDate: ahora,
      helpText: 'Fecha de nacimiento',
    );
    if (elegida != null) setState(() => _fechaNacimiento = elegida);
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      setState(() => _error = 'Selecciona tu fecha de nacimiento.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final usuarioService = context.read<UsuarioService>();
      // El backend espera fecha_nacimiento en formato YYYY-MM-DD (ver
      // UsuarioController.hpp: se cifra tal cual antes de guardarla).
      final fechaFormateada =
          '${_fechaNacimiento!.year.toString().padLeft(4, '0')}-'
          '${_fechaNacimiento!.month.toString().padLeft(2, '0')}-'
          '${_fechaNacimiento!.day.toString().padLeft(2, '0')}';

      final usuario = await usuarioService.registrar(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        fechaNacimiento: fechaFormateada,
      );

      await Session.instance.guardarUsuarioId(usuario.id);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ProfileFormScreen(usuarioId: usuario.id)),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Text('Crea tu cuenta',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Empieza tu plan personalizado en menos de 3 minutos.'),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  validator: (v) {
                    if (v == null || !v.contains('@')) return 'Ingresa un correo válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _elegirFecha,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
                    child: Text(
                      _fechaNacimiento == null
                          ? 'Selecciona una fecha'
                          : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  ErrorBanner(mensaje: _error!),
                  const SizedBox(height: 16),
                ],
                AppButton(texto: 'Continuar', cargando: _cargando, onPressed: _registrar),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'core/session.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/rutina_service.dart';
import 'services/solicitud_service.dart';
import 'services/usuario_service.dart';
import 'services/entrenamiento_service.dart';

void main() {
  runApp(const FormaIAApp());
}

class FormaIAApp extends StatelessWidget {
  const FormaIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Los servicios son instancias únicas para toda la app: comparten el
    // mismo ApiClient (y por lo tanto la misma URL base, ver
    // core/app_config.dart) en vez de que cada pantalla arme la suya.
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        ProxyProvider<ApiClient, UsuarioService>(
          update: (_, api, __) => UsuarioService(api),
        ),
        ProxyProvider<ApiClient, SolicitudService>(
          update: (_, api, __) => SolicitudService(api),
        ),
        ProxyProvider<ApiClient, RutinaService>(
          update: (_, api, __) => RutinaService(api),
        ),
        ProxyProvider<ApiClient, EntrenamientoService>(
          update: (_, api, __) => EntrenamientoService(api),
        ),
      ],
      child: MaterialApp(
        title: 'FormaIA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const _PantallaInicial(),
      ),
    );
  }
}

/// Decide si abrir directamente en Inicio (si ya hay un usuario_id
/// guardado localmente, ver core/session.dart) o en Bienvenida.
/// Esto es un sustituto simple de un chequeo de sesión/token real, que
/// se añadirá cuando el backend incorpore autenticación (ver el README
/// del backend, sección "No incluidos en este MVP").
class _PantallaInicial extends StatelessWidget {
  const _PantallaInicial();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: Session.instance.obtenerUsuarioId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final usuarioId = snapshot.data;
        if (usuarioId != null && usuarioId.isNotEmpty) {
          return HomeScreen(usuarioId: usuarioId);
        }
        return const WelcomeScreen();
      },
    );
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;

// Import condicional: en Android/iOS/desktop usa la variante con dart:io
// (target_platform_io.dart); en Flutter Web usa el stub, porque dart:io
// NO existe ahi y romper eso rompe `flutter build web` por completo, no
// solo en tiempo de ejecucion. Este es el patron estandar de Flutter para
// codigo que debe compilar tanto para web como para nativo.
import 'platform/target_platform_stub.dart'
    if (dart.library.io) 'platform/target_platform_io.dart' as target_platform;

/// Centraliza la URL base del backend en C++.
///
/// IMPORTANTE sobre "localhost" en dispositivos/emuladores moviles:
/// - iOS Simulator: "localhost" SI apunta a tu Mac, funciona tal cual.
/// - Emulador de Android: "localhost" apunta al propio emulador, no a tu
///   PC. Hay que usar la IP especial "10.0.2.2", que el emulador
///   redirige a la maquina anfitriona.
/// - Dispositivo fisico (Android o iOS) conectado por USB/Wi-Fi: hay que
///   usar la IP real de tu PC en la red local (ej. "192.168.1.50") y
///   asegurarte de que el backend escuche en HTTP_HOST=0.0.0.0 (ya es el
///   valor por defecto en .env.example del backend) y que el firewall
///   permita el puerto 8080.
///
/// Para no tocar codigo cada vez que cambias de entorno, se puede
/// sobreescribir con --dart-define=API_BASE_URL=http://192.168.1.50:8080
/// al compilar/correr: `flutter run --dart-define=API_BASE_URL=...`
class AppConfig {
  AppConfig._();

  static const _overrideDesdeDefine = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_overrideDesdeDefine.isNotEmpty) return _overrideDesdeDefine;
    if (kIsWeb) return 'http://localhost:8080';
    if (target_platform.esAndroid()) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  /// Tiempo maximo de espera por una respuesta antes de considerar que
  /// hay un problema de red (no confundir con el timeout de Groq del
  /// backend, que es interno y no bloquea esta peticion HTTP: el POST
  /// a /api/solicitudes-ia responde 202 de inmediato, ver
  /// SolicitudService).
  static const Duration timeoutHttp = Duration(seconds: 10);

  /// Cada cuanto se vuelve a preguntar por el estado de una solicitud
  /// mientras la IA la sigue procesando (ver SolicitudService.esperarResultado).
  static const Duration intervaloPolling = Duration(seconds: 2);

  /// Tiempo maximo total esperando a que la IA termine, antes de avisarle
  /// al usuario que algo tarda mas de lo normal.
  static const Duration timeoutPolling = Duration(seconds: 45);
}

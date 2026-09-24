import 'dart:io' show Platform;

/// Solo se compila cuando dart:io está disponible (Android, iOS, desktop),
/// gracias al import condicional en app_config.dart. En Flutter Web esta
/// librería NUNCA se incluye, así que dart:io no rompe esa build.
bool esAndroid() => Platform.isAndroid;
